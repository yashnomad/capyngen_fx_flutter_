import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:exness_clone/view/profile/add_account/model/bank.dart'
    as AddAccount;
import 'package:exness_clone/view/profile/user_profile/model/user_profile.dart'
    as Profile;

import '../../../../network/api_service.dart';
import '../../user_profile/bloc/user_profile_bloc.dart';
import '../../user_profile/bloc/user_profile_state.dart';

abstract class BankAccountEvent extends Equatable {
  const BankAccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadBankAccountFromProfile extends BankAccountEvent {}

class UpdateBankAccount extends BankAccountEvent {
  final String bankAccountNumber;
  final String ifscCode;
  final String bankName;

  const UpdateBankAccount({
    required this.bankAccountNumber,
    required this.ifscCode,
    required this.bankName,
  });

  @override
  List<Object?> get props => [bankAccountNumber, ifscCode, bankName];
}

class ResetBankAccount extends BankAccountEvent {}

abstract class BankAccountState extends Equatable {
  const BankAccountState();

  @override
  List<Object?> get props => [];
}

class BankAccountInitial extends BankAccountState {}

class BankAccountLoading extends BankAccountState {}

class BankAccountLoaded extends BankAccountState {
  final AddAccount.Bank bank;

  const BankAccountLoaded({required this.bank});

  @override
  List<Object?> get props => [bank];
}

class BankAccountEmpty extends BankAccountState {}

class BankAccountUpdateSuccess extends BankAccountState {
  final AddAccount.Bank bank;
  final String message;

  const BankAccountUpdateSuccess({
    required this.bank,
    required this.message,
  });

  @override
  List<Object?> get props => [bank, message];
}

class BankAccountError extends BankAccountState {
  final String error;

  const BankAccountError({required this.error});

  @override
  List<Object?> get props => [error];
}

class BankAccountBloc extends Bloc<BankAccountEvent, BankAccountState> {
  final UserProfileBloc userProfileBloc;

  BankAccountBloc({required this.userProfileBloc})
      : super(BankAccountInitial()) {
    on<LoadBankAccountFromProfile>(_onLoadBankAccountFromProfile);
    on<UpdateBankAccount>(_onUpdateBankAccount);
    on<ResetBankAccount>(_onResetBankAccount);
  }

  void _onLoadBankAccountFromProfile(
    LoadBankAccountFromProfile event,
    Emitter<BankAccountState> emit,
  ) {
    try {
      debugPrint('[BankAccountBloc] Loading bank account from profile');

      final profileState = userProfileBloc.state;

      if (profileState is UserProfileLoaded) {
        final Profile.Bank? userProfileBank =
            profileState.profile.profile?.bank;

        if (userProfileBank != null) {
          final bank = AddAccount.Bank(
            bankAccountNumber: userProfileBank.bankAccountNumber ?? '',
            ifscCode: userProfileBank.ifscCode ?? '',
            bankName: userProfileBank.bankName ?? '',
          );

          emit(BankAccountLoaded(bank: bank));
          debugPrint('[BankAccountBloc] Bank account loaded and converted');
        } else {
          emit(BankAccountEmpty());
          debugPrint('[BankAccountBloc] No bank data found');
        }
      } else {
        emit(const BankAccountError(error: 'Profile not loaded'));
        debugPrint('[BankAccountBloc] Profile not loaded yet');
      }
    } catch (e) {
      emit(BankAccountError(error: e.toString()));
      debugPrint('[BankAccountBloc] Error: $e');
    }
  }

  void _onUpdateBankAccount(
    UpdateBankAccount event,
    Emitter<BankAccountState> emit,
  ) async {
    try {
      debugPrint('[BankAccountBloc] Starting bank account update');
      emit(BankAccountLoading());

      final accountData = AddAccount.Bank(
        bankAccountNumber: event.bankAccountNumber,
        ifscCode: event.ifscCode,
        bankName: event.bankName,
      ).toJson();

      debugPrint('[BankAccountBloc] Sending data: $accountData');

      final response = await ApiService.updateBankAccount(accountData);

      if (response.success && response.data != null) {
        final updatedBank = _parseBankFromResponse(response.data);
        emit(BankAccountUpdateSuccess(
          bank: updatedBank,
          message: response.message ?? 'Bank details updated successfully',
        ));
        debugPrint('[BankAccountBloc] ✅ Bank updated');
      } else {
        emit(BankAccountError(
          error: response.message ?? 'Failed to update bank details',
        ));
        debugPrint('[BankAccountBloc] ⚠️ Update failed');
      }
    } catch (e) {
      emit(BankAccountError(error: e.toString()));
      debugPrint('[BankAccountBloc] ❌ Error: $e');
    }
  }

  void _onResetBankAccount(
    ResetBankAccount event,
    Emitter<BankAccountState> emit,
  ) {
    emit(BankAccountInitial());
  }

  AddAccount.Bank _parseBankFromResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final dataMap = responseData;
      if (dataMap.containsKey('data') &&
          dataMap['data'] is Map<String, dynamic>) {
        final nestedData = dataMap['data'];
        if (nestedData.containsKey('bank')) {
          return AddAccount.Bank.fromJson(nestedData['bank']);
        }
      } else if (dataMap.containsKey('bank')) {
        return AddAccount.Bank.fromJson(dataMap['bank']);
      }
    }
    throw Exception('Invalid bank response format');
  }
}
