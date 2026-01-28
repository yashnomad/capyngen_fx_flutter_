import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/switch_account_service.dart';
import 'cubit/trading_cubit.dart';
import 'cubit/trading_state.dart';
import 'model/follower_subscription_model.dart';
import 'model/master_account_model.dart';

class TradingManagementScreen extends StatelessWidget {
  const TradingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trading Management"),
          elevation: 0,
          bottom: TabBar(
            labelColor: AppFlavorColor.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppFlavorColor.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "COPY"),
              Tab(text: "MAM"),
              Tab(text: "PAMM"),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SwitchAccountService(accountBuilder: (context, account) {
            return BlocProvider(
              key: ValueKey(account.id),
              create: (context) => TradingCubit()
                ..fetchTradingData(
                  tradeUserId: account.id ?? "",
                  masterUserId: account.id ?? "",
                ),
              child: BlocBuilder<TradingCubit, TradingState>(
                builder: (context, state) {
                  if (state is TradingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is TradingError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is TradingLoaded) {
                    return TabBarView(
                      children: [
                        _AccountTabView(
                            mode: "COPY",
                            masters: state.masters,
                            followers: state.followers),
                        _AccountTabView(
                            mode: "MAM",
                            masters: state.masters,
                            followers: state.followers),
                        _AccountTabView(
                            mode: "PAMM",
                            masters: state.masters,
                            followers: state.followers),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AccountTabView extends StatelessWidget {
  final String mode;
  final List<MasterAccount> masters;
  final List<FollowerSubscription> followers;

  const _AccountTabView({
    required this.mode,
    required this.masters,
    required this.followers,
  });

  @override
  Widget build(BuildContext context) {
    final master = masters
        .where((m) => m.copyMode.toUpperCase() == mode.toUpperCase())
        .firstOrNull;

    if (master == null) {
      return _buildNotMasterUI();
    }

    final relevantFollowers =
        followers.where((f) => f.masterId == master.id).toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMasterHeader(master),
          const SizedBox(height: 32),
          _buildFollowersSection(relevantFollowers),
        ],
      ),
    );
  }

  Widget _buildMasterHeader(MasterAccount master) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${master.copyMode} Account",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            if (master.isActive) _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD7EEDF)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        "🥳 Account ${master.tradeAccount.accountID} is registered as a ${master.copyMode} Master Trader!",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text("Strategy: ${master.strategyName}",
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFollowersSection(List<FollowerSubscription> currentFollowers) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, color: Colors.indigo),
            const SizedBox(width: 8),
            Text("$mode Followers (${currentFollowers.length})",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        if (currentFollowers.isEmpty)
          _buildEmptyFollowersUI()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: currentFollowers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final f = currentFollowers[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text("Account: ${f.followerAccount.accountID}"),
                subtitle: Text("Status: ${f.status}"),
                trailing: Text("\$${f.allocationValue}"),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: const Text("Active",
          style: TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildEmptyFollowersUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          CircleAvatar(radius: 25, child: Icon(Icons.group)),
          SizedBox(height: 16),
          Text("No Followers Yet",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text("Followers will appear here once they join.",
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildNotMasterUI() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$mode Account",
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 50, color: Colors.blueGrey.shade300),
                const SizedBox(height: 20),
                Text("Not a $mode Master",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("This account is not set up for $mode Account.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
