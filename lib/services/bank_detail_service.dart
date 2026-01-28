import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/profile/add_account/bloc/bank_account_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';

class BankDetailService extends StatelessWidget {
  final bool provideBloc;

  const BankDetailService({super.key, this.provideBloc = false});

  @override
  Widget build(BuildContext context) {
    if (provideBloc) {
      return Builder(
        builder: (ctx) => BlocProvider(
          create: (_) =>
              BankAccountBloc(userProfileBloc: ctx.read<UserProfileBloc>())
                ..add(LoadBankAccountFromProfile()),
          child: _buildBody(),
        ),
      );
    } else {
      return _buildBody();
    }
  }

  Widget _buildBody() {
    return BlocBuilder<BankAccountBloc, BankAccountState>(
      builder: (context, state) {
        if (state is BankAccountLoaded || state is BankAccountUpdateSuccess) {
          final bank = state is BankAccountLoaded
              ? state.bank
              : (state as BankAccountUpdateSuccess).bank;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: true,
                  groupValue: true,
                  onChanged: (_) {},
                ),
                title: const Text(
                  "Bank Account",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  "Deposit funds directly to your linked bank account",
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              _buildReadOnlyTextField('Bank Name', bank.bankName, context),
              const SizedBox(height: 15),
              _buildReadOnlyTextField(
                  'Account Number', bank.bankAccountNumber, context),
              const SizedBox(height: 15),
              _buildReadOnlyTextField('IFSC Code', bank.ifscCode, context),
            ],
          );
        } else if (state is BankAccountError) {
          return Text('Error loading bank: ${state.error}',
              style: const TextStyle(color: Colors.red));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildReadOnlyTextField(String label, String value, BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          enabled: false,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(ctx).brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade100,
            // fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.mediumGrey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/profile/add_account/bloc/bank_account_bloc.dart';
import 'package:exness_clone/view/profile/user_profile/bloc/user_profile_bloc.dart';

class BankDetailService extends StatelessWidget {
  final bool provideBloc;

  const BankDetailService({super.key, this.provideBloc = false});

  @override
  Widget build(BuildContext context) {
    if (provideBloc) {
      return Builder(
        builder: (ctx) => BlocProvider(
          create: (_) =>
              BankAccountBloc(userProfileBloc: ctx.read<UserProfileBloc>())
                ..add(LoadBankAccountFromProfile()),
          child: _buildBody(),
        ),
      );
    } else {
      return _buildBody();
    }
  }

  Widget _buildBody() {
    return BlocBuilder<BankAccountBloc, BankAccountState>(
      builder: (context, state) {
        if (state is BankAccountLoaded || state is BankAccountUpdateSuccess) {
          final bank = state is BankAccountLoaded
              ? state.bank
              : (state as BankAccountUpdateSuccess).bank;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio(
                  value: true,
                  groupValue: true,
                  onChanged: (_) {},
                ),
                title: const Text("Bank Account"),
                subtitle: const Text(
                    "Deposit funds directly to your linked bank account"),
              ),
              const SizedBox(height: 10),
              _buildReadOnlyTextField('Bank Name', bank.bankName),
              const SizedBox(height: 15),
              _buildReadOnlyTextField('Account Number', bank.bankAccountNumber),
              const SizedBox(height: 15),
              _buildReadOnlyTextField('IFSC Code', bank.ifscCode),
            ],
          );
        } else if (state is BankAccountError) {
          return Text('Error loading bank: ${state.error}',
              style: const TextStyle(color: Colors.red));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          enabled: false,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.mediumGrey),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
*/
