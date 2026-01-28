import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/trade/bloc/accounts_bloc.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../trade/model/trade_account.dart';
import 'cubit/leaderboard_cubit.dart';
import 'cubit/leaderboard_state.dart';
import 'model/leaderboard_model.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Leaderboard",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: TabBar(
            labelColor: AppFlavorColor.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppFlavorColor.primary,
            tabs: [
              Tab(text: "Copy"),
              Tab(text: "MAM"),
              Tab(text: "PAM"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LeaderboardTab(key: ValueKey("COPY_TAB"), type: "COPY"),
            _LeaderboardTab(key: ValueKey("MAM_TAB"), type: "MAM"),
            _LeaderboardTab(key: ValueKey("PAMM_TAB"), type: "PAMM"),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatefulWidget {
  final String type;
  const _LeaderboardTab({super.key, required this.type});

  @override
  State<_LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<_LeaderboardTab> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaderboardCubit(type: widget.type),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) {
                if (state is LeaderboardLoading) {
                  return const Loader();
                } else if (state is LeaderboardError) {
                  return Center(child: Text(state.message));
                } else if (state is LeaderboardLoaded) {
                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<LeaderboardCubit>().fetchLeaderboard(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.traders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) =>
                          _buildTraderCard(context, state.traders[index]),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Find manager...",
          prefixIcon: Icon(
            Icons.search,
            color: AppFlavorColor.primary,
          ),
          filled: true,
          // fillColor: ,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
      ),
    );
  }

  Widget _buildTraderCard(BuildContext context, LeaderBoardModel trader) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1)
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(trader),
          const SizedBox(height: 16),
          _buildStatsRow(trader),
          const SizedBox(height: 16),
          _buildFollowButton(context, trader),
        ],
      ),
    );
  }

  Widget _buildCardHeader(LeaderBoardModel trader) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppFlavorColor.primary.withValues(alpha: 0.2),
          child: Text(trader.strategyName[0],
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppFlavorColor.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trader.strategyName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Manager",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("N/A",
                style: TextStyle(
                    color: Colors.red.shade400,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _buildStatsRow(LeaderBoardModel trader) {
    return Row(
      children: [
        _buildStatItem("Total Return", "${trader.sevenDayReturn}%"),
        const SizedBox(width: 12),
        _buildStatItem("AUM", "\$${trader.aum.toStringAsFixed(0)}"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, LeaderBoardModel trader) {
    final isFollowing = trader.followers == 1;
    final leaderboardCubit = context.read<LeaderboardCubit>();

    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        String? masterId;
        String? tradeAccountId;

        if (state is AccountsLoaded) {
          final allAccounts = state.tradeAccount.accounts;

          for (var account in allAccounts) {
            if (widget.type == "COPY") {
              if (account.copy?.id == trader.id) {
                masterId = account.copy?.id;
                tradeAccountId = account.copy?.tradeAccount;
                break;
              }
            } else if (widget.type == "MAM") {
              if (account.mam?.id == trader.id) {
                masterId = account.mam?.id;
                tradeAccountId = account.mam?.tradeAccount;
                break;
              }
            } else {
              if (account.pam?.id == trader.id) {
                masterId = account.pam?.id;
                tradeAccountId = account.pam?.tradeAccount;
                break;
              }
            }
          }
        }

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: masterId == null
                ? null
                : () => leaderboardCubit.followOrUnfollow(
                      masterId!,
                      tradeAccountId ?? '',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? AppFlavorColor.secondary
                  : AppFlavorColor.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              isFollowing ? "Following" : "Follow",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  /*
  Widget _buildFollowButton(BuildContext context, LeaderBoardModel trader) {
    final isFollowing = trader.followers == 1;

    return SwitchAccountService(
      accountBuilder: (context, account) {
        String? masterId;
        String? tradeAccountId;

        if (widget.type == "COPY") {
          if (account.copy?.id == trader.id) {
            masterId = account.copy?.id;
            tradeAccountId = account.copy?.tradeAccount;
          }
        } else if (widget.type == "MAM") {
          if (account.mam?.id == trader.id) {
            masterId = account.mam?.id;
            tradeAccountId = account.mam?.tradeAccount;
          }
        } else {
          if (account.pam?.id == trader.id) {
            masterId = account.pam?.id;
            tradeAccountId = account.pam?.tradeAccount;
          }
        }

        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: masterId == null
                ? null
                : () => context.read<LeaderboardCubit>().followOrUnfollow(
                      masterId!,
                      tradeAccountId ?? '',
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing
                  ? AppFlavorColor.secondary
                  : AppFlavorColor.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              isFollowing ? "Following" : "Follow",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        );
      },
    );
  }
*/
}
