import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../network/api_service.dart';
import '../model/trade_account.dart';

abstract class AccountsEvent extends Equatable {
  const AccountsEvent();

  @override
  List<Object> get props => [];
}

class LoadAccounts extends AccountsEvent {}

class RefreshAccounts extends AccountsEvent {}

abstract class AccountsState extends Equatable {
  const AccountsState();

  @override
  List<Object> get props => [];
}

class AccountsInitial extends AccountsState {}

class AccountsLoading extends AccountsState {}

class AccountsLoaded extends AccountsState {
  final TradeAccount tradeAccount;
  final List<Account> liveAccounts;
  final List<Account> demoAccounts;
  final List<Account> archivedAccounts;

  const AccountsLoaded({
    required this.tradeAccount,
    required this.liveAccounts,
    required this.demoAccounts,
    required this.archivedAccounts,
  });

  @override
  List<Object> get props =>
      [tradeAccount, liveAccounts, demoAccounts, archivedAccounts];
}

class AccountsError extends AccountsState {
  final String message;

  const AccountsError(this.message);

  @override
  List<Object> get props => [message];
}

class AccountsBloc extends Bloc<AccountsEvent, AccountsState> {
  AccountsBloc() : super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<RefreshAccounts>(_onRefreshAccounts);
  }

  Future<void> _onLoadAccounts(
      LoadAccounts event, Emitter<AccountsState> emit) async {
    emit(AccountsLoading());
    await _fetchAccounts(emit);
  }

  Future<void> _onRefreshAccounts(
      RefreshAccounts event, Emitter<AccountsState> emit) async {
    await _fetchAccounts(emit);
  }

  Future<void> _fetchAccounts(Emitter<AccountsState> emit) async {
    try {
      final response = await ApiService.getTradeAccounts();
      if (response.success && response.data != null) {
        final tradeAccount =
            TradeAccount.fromJson(response.data as Map<String, dynamic>);

        for (int i = 0; i < tradeAccount.accounts.length; i++) {
          final account = tradeAccount.accounts[i];
        }

        final liveAccounts = tradeAccount.accounts
            .where((account) =>
                account.accountType?.toLowerCase() == 'live' &&
                account.status?.toLowerCase() != 'archived')
            .toList();

        final demoAccounts = tradeAccount.accounts
            .where((account) =>
                account.accountType?.toLowerCase() == 'demo' &&
                account.status?.toLowerCase() != 'archived')
            .toList();

        final archivedAccounts = tradeAccount.accounts
            .where((account) => account.status?.toLowerCase() == 'archived')
            .toList();

        emit(AccountsLoaded(
          tradeAccount: tradeAccount,
          liveAccounts: liveAccounts,
          demoAccounts: demoAccounts,
          archivedAccounts: archivedAccounts,
        ));
      } else {
        emit(AccountsError(response.message ?? 'Failed to load accounts'));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception in _fetchAccounts: $e');
      debugPrint('❌ StackTrace: $stackTrace');
      emit(AccountsError('An error occurred: ${e.toString()}'));
    }
  }
}
