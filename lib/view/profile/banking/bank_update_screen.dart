import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/utils/validators.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';

// Imports for Cubit/State
import '../../../theme/app_colors.dart';
import 'cubit/payment_methods_cubit.dart';
import '../user_profile/bloc/user_profile_bloc.dart';

class UpdateBankScreen extends StatefulWidget {
  const UpdateBankScreen({super.key});

  @override
  State<UpdateBankScreen> createState() => _UpdateBankScreenState();
}

class _UpdateBankScreenState extends State<UpdateBankScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Initialize Cubit
      create: (context) => PaymentMethodsCubit(
        userProfileBloc: context.read<UserProfileBloc>(),
      )..loadInitialData(),

      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          title: const Text("Update Withdraw",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppFlavorColor.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppFlavorColor.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Bank"),
              Tab(text: "UPI"),
              Tab(text: "Crypto"),
            ],
          ),
        ),
        body: BlocListener<PaymentMethodsCubit, PaymentMethodsState>(
          listenWhen: (previous, current) =>
              current.errorMessage != null || current.successMessage != null,
          listener: (context, state) {
            if (state.errorMessage != null) {
              SnackBarService.showError(state.errorMessage!);
            }
            if (state.successMessage != null) {
              SnackBarService.showSuccess(state.successMessage!);
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: const [
              _BankTab(),
              _UpiTab(),
              _CryptoTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 1: BANK ---
class _BankTab extends StatelessWidget {
  const _BankTab();

  @override
  Widget build(BuildContext context) {
    final bankNameCtrl = TextEditingController();
    final accNumCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
      listener: (context, state) {
        if (bankNameCtrl.text.isEmpty) {
          bankNameCtrl.text = state.withdrawalDetails.bankName;
          accNumCtrl.text = state.withdrawalDetails.bankAccountNumber;
          ifscCtrl.text = state.withdrawalDetails.ifscCode;
        }
      },
      builder: (context, state) {
        if (state.status == PaymentStatus.loading &&
            state.withdrawalDetails.bankName.isEmpty) {
          return const Loader();
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: formKey,
              child: Column(
                children: [
                  _buildField(context, "Bank Name", bankNameCtrl,
                      Icons.account_balance, Validators.validateBankName),
                  const SizedBox(height: 16),
                  _buildField(context, "Account Number", accNumCtrl,
                      Icons.numbers, Validators.validateAccountNumber,
                      type: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildField(context, "IFSC Code", ifscCtrl, Icons.code,
                      Validators.validateIFSC,
                      caps: TextCapitalization.characters),
                  const SizedBox(height: 32),
                  PremiumAppButtonVariants.primary(
                    isLoading: state.status == PaymentStatus.loading,
                    text: "Save Bank Details",
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Call Cubit Function
                        context.read<PaymentMethodsCubit>().updateBankOrUpi(
                              bankName: bankNameCtrl.text,
                              accountNum: accNumCtrl.text,
                              ifsc: ifscCtrl.text,
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// --- TAB 2: UPI ---
// --- TAB 2: UPI ---
class _UpiTab extends StatefulWidget {
  const _UpiTab();

  @override
  State<_UpiTab> createState() => _UpiTabState();
}

class _UpiTabState extends State<_UpiTab> {
  final _upiCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false; // Controls View vs Edit mode

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentMethodsCubit, PaymentMethodsState>(
      listener: (context, state) {
        // If we just saved successfully, switch back to View Mode
        if (state.status == PaymentStatus.success && _isEditing) {
          setState(() {
            _isEditing = false;
          });
        }

        // Pre-fill controller if empty
        if (_upiCtrl.text.isEmpty) {
          _upiCtrl.text = state.withdrawalDetails.upiId;
        }
      },
      builder: (context, state) {
        final savedUpi = state.withdrawalDetails.upiId;
        final hasSavedUpi = savedUpi.isNotEmpty;

        // 1. VIEW MODE: Show Card if data exists and we aren't editing
        if (hasSavedUpi && !_isEditing) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Saved UPI Method",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),

                // The "Crypto-style" Card
                Container(
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code, color: Colors.purple),
                    ),
                    title: const Text(
                      "UPI ID",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    subtitle: Text(
                      savedUpi,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        // color: Colors.black87,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: AppFlavorColor.primary),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                          _upiCtrl.text =
                              savedUpi; // Ensure text is ready to edit
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 2. EDIT MODE: Show Form
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (hasSavedUpi) ...[
                  // Header to cancel edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Update UPI Details",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: const Text("Cancel"),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: AppFlavorColor.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "UPI ID must match your registered bank account.",
                          style: TextStyle(
                              color: AppFlavorColor.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildField(context, "UPI ID / VPA", _upiCtrl, Icons.qr_code,
                    (v) => v!.isEmpty ? "Required" : null,
                    hint: "example@okbank"),
                const Spacer(),
                PremiumAppButtonVariants.primary(
                  isLoading: state.status == PaymentStatus.loading,
                  text: hasSavedUpi ? "Update UPI ID" : "Link UPI ID",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<PaymentMethodsCubit>().updateBankOrUpi(
                            upiId: _upiCtrl.text,
                          );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- TAB 3: CRYPTO ---
class _CryptoTab extends StatefulWidget {
  const _CryptoTab();

  @override
  State<_CryptoTab> createState() => _CryptoTabState();
}

class _CryptoTabState extends State<_CryptoTab> {
  String selectedNetwork = "TRC20";
  final addressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.supportedNetworks.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: state.supportedNetworks.map((network) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 26,
                      child: _networkCard(network),
                    );
                  }).toList(),
                )
              else
                const Text(
                  "No crypto networks available",
                  style: TextStyle(color: Colors.grey),
                ),
              const SizedBox(height: 20),
              _buildField(context, "Wallet Address", addressCtrl, Icons.wallet,
                  (v) => null,
                  hint: "Enter USDT address"),
              const SizedBox(height: 20),
              PremiumAppButtonVariants.primary(
                isLoading: state.isCryptoActionLoading,
                text: "Add $selectedNetwork Wallet",
                onPressed: () {
                  if (addressCtrl.text.isNotEmpty) {
                    // Call Cubit Function
                    context.read<PaymentMethodsCubit>().addCryptoWallet(
                          currency: "USDT",
                          network: selectedNetwork,
                          address: addressCtrl.text,
                        );
                  }
                },
              ),
              const Divider(height: 40),
              const Text("Saved Wallets",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (state.cryptoWallets.isEmpty)
                const Text("No wallets added yet.",
                    style: TextStyle(color: Colors.grey))
              else
                ...state.cryptoWallets.map((w) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.currency_bitcoin,
                            color: Colors.green),
                        title: Text(w.label),
                        subtitle: Text(w.address),
                        trailing: Text(w.network),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _networkCard(String network) {
    final isSel = selectedNetwork == network;
    return InkWell(
      onTap: () => setState(() => selectedNetwork = network),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? AppFlavorColor.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
              color: isSel ? AppFlavorColor.primary : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(network,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSel ? AppFlavorColor.primary : Colors.grey)),
      ),
    );
  }
}

// Helper Widget
Widget _buildField(
    BuildContext context,
    String label,
    TextEditingController ctrl,
    IconData icon,
    String? Function(String?)? validator,
    {String? hint,
    TextInputType? type,
    TextCapitalization caps = TextCapitalization.none}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
        // color: Colors.white,
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
        ]),
    child: TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: type,
      textCapitalization: caps,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          hintText: hint),
    ),
  );
}
