import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/saving_cubit.dart';
import 'model/investment_model.dart';
import 'model/saving_model.dart';

class SavingScreen extends StatelessWidget {
  const SavingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SavingCubit()..loadPageData();
      },
      child: const SavingScreenView(),
    );
  }
}

class SavingScreenView extends StatefulWidget {
  const SavingScreenView({super.key});

  @override
  State<SavingScreenView> createState() => _SavingScreenViewState();
}

class _SavingScreenViewState extends State<SavingScreenView> {
  int _selectedIndex = 0; // 0 = Available, 1 = My Savings
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleAppbar(title: 'Saving'),
      body: SafeArea(
        child: Column(
          children: [
            _activeAccountCard(),

            // TABS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(child: _buildTabBtn("Available Savings", 0)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTabBtn("My Savings", 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // BODY
            Expanded(
              child: BlocBuilder<SavingCubit, SavingState>(
                builder: (context, state) {
                  if (state is SavingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SavingLoaded) {
                    // Switch lists based on tab
                    if (_selectedIndex == 0) {
                      return _buildPackageList(state.packages);
                    } else {
                      return _buildInvestmentList(state.myInvestments);
                    }
                  } else if (state is SavingError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- List Views ---

  Widget _buildPackageList(List<SavingPackage> packages) {
    if (packages.isEmpty) {
      return const Center(child: Text("No Packages Available"));
    }
    return ListView.builder(
      itemCount: packages.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => _buildPackageCard(packages[index]),
    );
  }

  Widget _buildInvestmentList(List<UserInvestment> investments) {
    if (investments.isEmpty) return _noSavings();
    return ListView.builder(
      itemCount: investments.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => _buildInvestmentCard(investments[index]),
    );
  }

  // --- Cards ---

  Widget _buildPackageCard(SavingPackage pkg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF1E6CFF),
                radius: 18,
                child: Icon(Icons.attach_money, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pkg.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(pkg.roiType,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Text("${pkg.roiPercentage}%",
              style:
                  const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text("${pkg.roiType} Return",
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          _infoRow("Min Amount", "${pkg.amount} USD"),
          const SizedBox(height: 8),
          _infoRow("Lock-in", "${pkg.lockInPeriod} days"),
          const SizedBox(height: 20),
          PremiumAppButton(
            text: 'Subscribe',
            onPressed: () => _showSubscribeDialog(pkg),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(UserInvestment inv) {
    bool isRunning = inv.investmentStatus == 'running';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF00C853),
                radius: 18,
                child: Icon(Icons.savings, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Active Investment",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("Daily",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),
          Text("${inv.roiPercentage}%",
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const Text("Daily Return", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 15),
          _infoRow("Invested", "${CommonUtils.formatBalance(inv.investedAmount.toDouble())} USD"),
          // _infoRow("Invested", "${inv.investedAmount} USD"),
          const SizedBox(height: 8),
          _infoRow("Profit", "\$${inv.totalProfitEarned}",
              color: const Color(0xFF00C853)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status", style: TextStyle(color: Colors.grey)),
              Text(inv.investmentStatus.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isRunning ? const Color(0xFF00C853) : Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  // --- Dialog & Helper Widgets ---

  void _showSubscribeDialog(SavingPackage pkg) {
    _amountController.text = pkg.amount.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Subscribe to ${pkg.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount to Invest"),
            ),
            const SizedBox(height: 10),
            _infoRow("Lock-in Period", "${pkg.lockInPeriod} days"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppFlavorColor.primary),
            onPressed: () {
              final amount = num.tryParse(_amountController.text) ?? 0;
              if (amount >= pkg.amount) {
                // Call API 3 via Cubit
                context.read<SavingCubit>().subscribe(pkg.id, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _infoRow(String k, String v, {Color color = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(k, style: const TextStyle(color: Colors.grey)),
        Text(v, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildTabBtn(String title, int idx) {
    bool active = _selectedIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppFlavorColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: active ? AppFlavorColor.primary : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(title,
            style: TextStyle(color: active ? Colors.white : Colors.black54)),
      ),
    );
  }

  Widget _noSavings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppFlavorColor.primary.withOpacity(0.3)),
          child: const Icon(CupertinoIcons.doc),
        ),
        const SizedBox(height: 10),
        const Text('No Active Savings',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ],
    );
  }

  Widget _activeAccountCard() {
    final data = StorageService.getSelectedAccount();
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppFlavorColor.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color:  AppFlavorColor.primary.withValues(alpha: 0.1),),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card, color: AppFlavorColor.primary, size: 30),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Active Account: ${data?.accountId}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Balance: ${CommonUtils.formatBalance(data?.balance?.toDouble())} USD"),
              // Text("Balance: ${data?.balance} USD"),
            ],
          ),
        ],
      ),
    );
  }
}
