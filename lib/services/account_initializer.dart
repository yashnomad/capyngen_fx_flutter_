import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view/trade/bloc/accounts_bloc.dart';
import '../view/account/withdraw_deposit/bloc/select_account_bloc.dart';

class AccountInitializer extends StatelessWidget {
  final Widget child;

  const AccountInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listenWhen: (previous, current) =>
      previous != current && current is AccountsLoaded,
      listener: (context, state) {
        if (state is AccountsLoaded) {
          final cubit = context.read<SelectedAccountCubit>();

          final hasNoAccounts =
              state.liveAccounts.isEmpty && state.demoAccounts.isEmpty;

          if (hasNoAccounts) {
            cubit.clearAccount();
            return;
          }

          final saved = cubit.state;

          if (saved != null) {
            final all = [...state.liveAccounts, ...state.demoAccounts];

            final exists = all.any((a) => a.id == saved.id);

            if (!exists) {
              cubit.clearAccount();
            } else {
              final match = all.firstWhere((a) => a.id == saved.id);
              cubit.selectAccount(match);
            }
            return;
          }

          final firstLive =
          state.liveAccounts.isNotEmpty ? state.liveAccounts.first : null;
          final firstDemo =
          state.demoAccounts.isNotEmpty ? state.demoAccounts.first : null;

          if (firstLive != null) {
            cubit.selectAccount(firstLive);
          } else if (firstDemo != null) {
            cubit.selectAccount(firstDemo);
          }
        }
      },
      child: child,
    );
  }
}

/*
class AccountInitializer extends StatelessWidget {
  final Widget child;

  const AccountInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountsBloc, AccountsState>(
      listenWhen: (previous, current) =>
          previous != current && current is AccountsLoaded,
      listener: (context, state) {
        if (state is AccountsLoaded) {
          final cubit = context.read<SelectedAccountCubit>();
          final saved = cubit.state;

          if (saved != null) {
            // verify if saved account still exists
            final all = [...state.liveAccounts, ...state.demoAccounts];
            final match = all.firstWhere(
              (a) => a.id == saved.id,
              orElse: () => saved,
            );

            cubit.selectAccount(match);
            return;
          }

          final firstLive =
              state.liveAccounts.isNotEmpty ? state.liveAccounts.first : null;
          final firstDemo =
              state.demoAccounts.isNotEmpty ? state.demoAccounts.first : null;

          if (firstLive != null) {
            cubit.selectAccount(firstLive);
          } else if (firstDemo != null) {
            cubit.selectAccount(firstDemo);
          }
        }
      },
      child: child,
    );
  }
}*/
