import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/profile/add_account/model/bank.dart';
import 'package:exness_clone/widget/button/app_button.dart';
import 'package:flutter/material.dart';
import 'package:exness_clone/utils/validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../widget/button/premium_app_button.dart';
import '../../../widget/shimmer/bank_shimmer.dart';
import '../user_profile/bloc/user_profile_bloc.dart';
import '../user_profile/bloc/user_profile_event.dart';
import '../user_profile/bloc/user_profile_state.dart';
import 'bloc/bank_account_bloc.dart';

class AddBankAccount extends StatefulWidget {
  const AddBankAccount({super.key});

  @override
  State<AddBankAccount> createState() => _AddBankAccountState();
}

class _AddBankAccountState extends State<AddBankAccount>
    with TickerProviderStateMixin {
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
  TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
    late final BankAccountBloc _bankAccountBloc;
  final _formKey = GlobalKey<FormState>();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Focus nodes for enhanced interactions
  final FocusNode _bankNameFocus = FocusNode();
  final FocusNode _accountNumberFocus = FocusNode();
  final FocusNode _ifscCodeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _bankAccountBloc = BankAccountBloc(
      userProfileBloc: context.read<UserProfileBloc>(),
    );

    // Initialize animations
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bankAccountBloc.add(LoadBankAccountFromProfile());
    });
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _bankNameFocus.dispose();
    _accountNumberFocus.dispose();
    _ifscCodeFocus.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    _bankAccountBloc.close();
    super.dispose();
  }

    void _fillFormWithBankData(Bank bank) {
      _bankNameController.text = bank.bankName;
      _accountNumberController.text = bank.bankAccountNumber;
      _ifscCodeController.text = bank.ifscCode;
    }

  void _onSavePressed() {
    final state =
        context.read<UserProfileBloc>().state;

    if (state is UserProfileLoaded) {
      final kycStatus =
          state.profile.profile?.kycStatus;
      if (kycStatus != 'verified') {
        SnackBarService.showError(
            "KYC verification is required for Live Accounts.");
        context.push('/kycVerification');
      } else {
        if (_formKey.currentState?.validate() ?? false) {
          _bankAccountBloc.add(UpdateBankAccount(
            bankAccountNumber: _accountNumberController.text,
            ifscCode: _ifscCodeController.text,
            bankName: _bankNameController.text,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      bottomNavigationBar: BlocProvider.value(
        value: _bankAccountBloc,
        child: BlocListener<BankAccountBloc, BankAccountState>(
          listener: (context, state) {
            if (state is BankAccountLoaded) {
              _fillFormWithBankData(state.bank);
            } else if (state is BankAccountUpdateSuccess) {
              _fillFormWithBankData(state.bank);
              context.read<UserProfileBloc>().add(FetchUserProfile());
              SnackBarService.showSuccess(state.message);
            } else if (state is BankAccountError) {
              SnackBarService.showError(state.error);
            }
          },
          child: BlocBuilder<BankAccountBloc, BankAccountState>(
            builder: (context, state) {
              if (state is BankAccountLoading) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 20,
                    right: 20,
                  ),
                  child: const BankFormShimmer(),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color:context.backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: PremiumAppButtonVariants.secondary(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PremiumAppButtonVariants.primary(
                          text: 'Save Bank Details',
                          icon: Icons.account_balance,
                          showIcon: true,
                          onPressed: _onSavePressed,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:context.bottomSheetGradientColor
        ),
        child: Column(
          children: [
            // Premium App Bar
            Container(
              decoration: BoxDecoration(
                color: context.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppFlavorColor.primary,
                      AppFlavorColor.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppFlavorColor.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Icons.account_balance,
                          color: AppColor.whiteColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bank Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: context.themeColor,
                              ),
                            ),
                            Text(
                              'Secure banking information',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColor.greyColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.lightGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: AppColor.greyColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Form Content
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          const SizedBox(height: 10),
                          _buildPremiumFormField(
                            label: 'Bank Name',
                            controller: _bankNameController,
                            focusNode: _bankNameFocus,
                            hintText: 'Enter your bank name',
                            validator: Validators.validateBankName,
                            icon: Icons.account_balance,
                            nextFocus: _accountNumberFocus,
                          ),
                          const SizedBox(height: 24),
                          _buildPremiumFormField(
                            label: 'Account Number',
                            controller: _accountNumberController,
                            focusNode: _accountNumberFocus,
                            hintText: 'Enter your account number',
                            keyboardType: TextInputType.number,
                            validator: Validators.validateAccountNumber,
                            icon: Icons.credit_card,
                            nextFocus: _ifscCodeFocus,
                          ),
                          const SizedBox(height: 24),
                          _buildPremiumFormField(
                            label: 'IFSC Code',
                            controller: _ifscCodeController,
                            focusNode: _ifscCodeFocus,
                            hintText: 'Enter IFSC code',
                            validator: Validators.validateIFSC,
                            icon: Icons.numbers,
                            textCapitalization: TextCapitalization.characters,
                          ),
                          const SizedBox(height: 32),
                          _buildInfoCard(),
                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFormField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? nextFocus,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {


    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        final hasText = controller.text.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isFocused
                ? [
              BoxShadow(
                color: AppColor.darkBlueColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Floating Label
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isFocused || hasText
                            ? AppColor.darkBlueColor
                            : AppColor.greyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 16,
                        color: isFocused || hasText
                            ? AppColor.whiteColor
                            : AppColor.greyColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isFocused
                            ? AppFlavorColor.primary
                            : context.themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Text Field
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: isFocused
                      ? LinearGradient(
                    colors: [
                      AppColor.darkBlueColor.withOpacity(0.05),
                      AppColor.darkBlueColor.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  color: isFocused
                      ? null
                      : context.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFocused
                        ? AppColor.darkBlueColor
                        : AppColor.mediumGrey.withOpacity(0.3),
                    width: isFocused ? 2 : 1,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  validator: validator,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  onFieldSubmitted: (_) {
                    if (nextFocus != null) {
                      FocusScope.of(context).requestFocus(nextFocus);
                    }
                  },
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color:context.themeColor,
                  ),
                  cursorColor: AppFlavorColor.primary,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: AppColor.greyColor.withOpacity(0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppFlavorColor.primary.withOpacity(0.1),
                  AppFlavorColor.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppFlavorColor.primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppFlavorColor.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppFlavorColor.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppFlavorColor.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child:  Icon(
                    Icons.security,
                    color:AppColor.whiteColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Notice',
                        style: TextStyle(
                          color: AppFlavorColor.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your bank details will be securely reviewed by our admin team before approval. Please ensure all information is accurate and matches your bank records.',
                        style: TextStyle(
                          color: AppFlavorColor.primary.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
