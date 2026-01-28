import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/trade/bloc/accounts_bloc.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../network/api_service.dart';
import '../../utils/kyc_gaurd.dart';
import '../../utils/snack_bar.dart';
import '../profile/user_profile/bloc/user_profile_bloc.dart';
import '../profile/user_profile/bloc/user_profile_state.dart';
import 'model/company_group_model.dart';

class OpenNewAccount extends StatefulWidget {
  final String accountType;
  const OpenNewAccount({super.key, required this.accountType});

  @override
  State<OpenNewAccount> createState() => _OpenNewAccountState();
}

class _OpenNewAccountState extends State<OpenNewAccount> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int currentPage = 0;
  String? _selectedGroup;
  String _selectedCurrency = "USD";

  List<CompanyGroup> _companyGroups = [];
  bool _isLoading = false;

  final _kycService = KycService();


  @override
  void initState() {
    super.initState();
    fetchCompanyGroups();
  }

  // Future<void> fetchCompanyGroups() async {
  //   setState(() => _isLoading = true);
  //
  //   final response = await ApiService.companyGroup();
  //
  //   if (response.success && response.data != null) {
  //     final companyGroupResponse =
  //         CompanyGroupResponse.fromJson(response.data!);
  //
  //     setState(() {
  //       _companyGroups = companyGroupResponse.results;
  //       _isLoading = false;
  //     });
  //
  //     debugPrint("✅ Company Groups Loaded: ${_companyGroups.length}");
  //   } else {
  //     setState(() => _isLoading = false);
  //     debugPrint("❌ Failed to load company groups");
  //   }
  // }

  Future<void> fetchCompanyGroups() async {
    setState(() => _isLoading = true);

    final response = await ApiService.companyGroup();

    if (response.success && response.data != null) {
      final companyGroupResponse =
      CompanyGroupResponse.fromJson(response.data!);

      final activeGroups = companyGroupResponse.results
          .where((g) => g.status.trim().toLowerCase() == 'yes')
          .toList();

      setState(() {
        _companyGroups = companyGroupResponse.results;
        _selectedGroup = activeGroups.first.groupName;
        _isLoading = false;
      });
    }
  }


  Future<void> _createAccount(
      {required String accountType,
      required String currency,
      required String group}) async {
    try {
      final allowed = await _kycService.checkAndHandleKyc(context);

      if (!allowed) return;

      final response = await ApiService.createTradeAccount({
        "accountType": accountType.toLowerCase(),
        "currency": currency.toUpperCase(),
        "group": group.trim()
      });

      // group: Vip | Micro | Standard

      if (response.success == true && response.data != null) {
        SnackBarService.showSuccess(response.data?['message']);
      } else {
        SnackBarService.showError(response.message ?? '');
      }
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          color: context.scaffoldBackgroundColor,
        ),
        title: const Text(
          "Open new account",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.47,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _companyGroups.isEmpty
                    ? const Center(child: Text("0 Company Groups Found"))
                    : Builder(
                        builder: (context) {
                          // 🔹 Only show accounts with status == "yes"
                          final activeGroups = _companyGroups
                              .where((acc) =>
                                  acc.status.trim().toLowerCase() == 'yes')
                              .toList();

                          // 🔹 Handle case where no active accounts
                          if (activeGroups.isEmpty) {
                            return const Center(
                                child: Text("No active accounts found"));
                          }

                          return PageView.builder(
                            controller: _pageController,
                            itemCount: activeGroups.length,
                            onPageChanged: (index) => setState(() {
                              currentPage = index;
                              _selectedGroup = activeGroups[index].groupName;
                            }),
                            itemBuilder: (context, index) {
                              final acc = activeGroups[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _AccountCardDynamic(account: acc),
                              );
                            },
                          );
                        },
                      ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              // 🔹 Use only active accounts for indicators
              _companyGroups
                  .where((acc) => acc.status.trim().toLowerCase() == 'yes')
                  .length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index
                      ? context.openNewAccountBoxColor
                      : AppColor.mediumGrey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Contract Specifications",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Detailed information on our instruments and trading conditions",
              style: TextStyle(
                  fontSize: 12,
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PremiumAppButton(
              isDisabled: _companyGroups.isEmpty,
              text: 'Continue',
              onPressed: () async {
                await _createAccount(
                  accountType: widget.accountType,
                  currency: _selectedCurrency,
                  group: _selectedGroup ?? '',
                );

                debugPrint("Account group: $_selectedGroup");
                if (context.mounted) {
                  context.read<AccountsBloc>().add(RefreshAccounts());
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCardDynamic extends StatelessWidget {
  final CompanyGroup account;
  const _AccountCardDynamic({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.mediumGrey),
        borderRadius: BorderRadius.circular(12),
        color: context.backgroundColor,
      ),
      child: Column(
        children: [
          Text(
            account.groupName,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppFlavorColor.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 14, color: AppColor.whiteColor),
                const SizedBox(width: 4),
                Text(
                  "Recommended",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.whiteColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Swap Days: ${account.swapDays}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Divider(color: AppColor.mediumGrey),
          _infoRow("Min Deposit", "${account.minDeposit} USD"),
          Divider(color: AppColor.mediumGrey),
          _infoRow("Max Deposit", "${account.maxDeposit} USD"),
          Divider(color: AppColor.mediumGrey),
          _infoRow("Commission", "${account.commision} USD"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColor.greyColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
