import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exness_clone/network/api_service.dart';
import '../../user_profile/bloc/user_profile_bloc.dart';
import '../../user_profile/bloc/user_profile_event.dart';
import '../../user_profile/bloc/user_profile_state.dart';
import '../model/withdraw_detail.dart';
import '../model/crypto_wallet.dart';

enum PaymentStatus { initial, loading, success, failure }

class PaymentMethodsState extends Equatable {
  final List<String> supportedNetworks;
  final PaymentStatus status;
  final WithdrawalDetails withdrawalDetails;
  final List<CryptoWallet> cryptoWallets;
  final String? errorMessage;
  final String? successMessage;
  final bool isCryptoActionLoading;

  const PaymentMethodsState({
    this.status = PaymentStatus.initial,
    required this.withdrawalDetails,
    this.cryptoWallets = const [],
    this.supportedNetworks = const ['TRC20', 'BEP20'],
    this.errorMessage,
    this.successMessage,
    this.isCryptoActionLoading = false,
  });

  factory PaymentMethodsState.initial() {
    return PaymentMethodsState(
      withdrawalDetails: WithdrawalDetails(),
    );
  }

  PaymentMethodsState copyWith({
    PaymentStatus? status,
    WithdrawalDetails? withdrawalDetails,
    List<CryptoWallet>? cryptoWallets,
    List<String>? supportedNetworks,
    String? errorMessage,
    String? successMessage,
    bool? isCryptoActionLoading,
  }) {
    return PaymentMethodsState(
      status: status ?? this.status,
      withdrawalDetails: withdrawalDetails ?? this.withdrawalDetails,
      cryptoWallets: cryptoWallets ?? this.cryptoWallets,
      supportedNetworks: supportedNetworks ?? this.supportedNetworks,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isCryptoActionLoading:
          isCryptoActionLoading ?? this.isCryptoActionLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        withdrawalDetails.toApiJson(),
        cryptoWallets,
        supportedNetworks,
        errorMessage,
        successMessage,
        isCryptoActionLoading
      ];
}

class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  final UserProfileBloc userProfileBloc;
  late StreamSubscription _profileSubscription;

  PaymentMethodsCubit({required this.userProfileBloc})
      : super(PaymentMethodsState.initial()) {
    _profileSubscription = userProfileBloc.stream.listen((profileState) {
      if (profileState is UserProfileLoaded) {
        _updateFromProfile(profileState);
      }
    });
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  void _updateFromProfile(UserProfileLoaded profileState) {
    final profile = profileState.profile.profile;

    final newDetails = WithdrawalDetails(
      bankName: profile?.bank?.bankName ?? '',
      bankAccountNumber: profile?.bank?.bankAccountNumber ?? '',
      ifscCode: profile?.bank?.ifscCode ?? '',
      upiId: profile?.upiDetails?.upiId ?? '',
      providerName: profile?.upiDetails?.providerName ?? '',
    );

    if (state.withdrawalDetails != newDetails) {
      emit(state.copyWith(withdrawalDetails: newDetails));
    }
  }

  Future<void> loadInitialData() async {
    if (userProfileBloc.state is UserProfileLoaded) {
      _updateFromProfile(userProfileBloc.state as UserProfileLoaded);
    }

    emit(state.copyWith(status: PaymentStatus.loading));
    try {
      List<CryptoWallet> wallets = [];
      final cryptoRes = await ApiService.getCryptoAddress();

      if (cryptoRes.success && cryptoRes.data?['results'] != null) {
        wallets = (cryptoRes.data?['results'] as List)
            .map((e) => CryptoWallet.fromJson(e))
            .toList();
      }

      emit(state.copyWith(
        status: PaymentStatus.success,
        cryptoWallets: wallets,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: PaymentStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateBankOrUpi({
    String? bankName,
    String? accountNum,
    String? ifsc,
    String? upiId,
  }) async {
    emit(state.copyWith(status: PaymentStatus.loading));

    try {
      final updatedDetails = state.withdrawalDetails.copyWith(
        bankName: bankName,
        bankAccountNumber: accountNum,
        ifscCode: ifsc,
        upiId: upiId,
        providerName:
            upiId != null ? "UPI" : state.withdrawalDetails.providerName,
      );

      final response =
          await ApiService.updateBankAccount(updatedDetails.toApiJson());

      if (response.success) {
        userProfileBloc.add(FetchUserProfile());

        emit(state.copyWith(
          status: PaymentStatus.success,
          withdrawalDetails: updatedDetails,
          successMessage: response.message ?? "Details updated successfully",
        ));
      } else {
        emit(state.copyWith(
            status: PaymentStatus.failure,
            errorMessage: response.message ?? "Update failed"));
      }
    } catch (e) {
      emit(state.copyWith(
          status: PaymentStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> addCryptoWallet({
    required String currency,
    required String network,
    required String address,
  }) async {
    emit(state.copyWith(isCryptoActionLoading: true));

    try {
      final data = {
        "currency": currency,
        "network": network,
        "address": address,
        "label": "$currency $network Wallet",
        "isDefault": true
      };

      final response = await ApiService.createCryptoAddress(data);

      if (response.success) {
        await loadInitialData();
        emit(state.copyWith(
          isCryptoActionLoading: false,
          successMessage: response.message ?? "Wallet linked successfully",
        ));
      } else {
        emit(state.copyWith(
            isCryptoActionLoading: false, errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isCryptoActionLoading: false, errorMessage: e.toString()));
    }
  }
}
