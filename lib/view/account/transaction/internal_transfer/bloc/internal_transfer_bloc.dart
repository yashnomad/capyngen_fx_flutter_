import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:exness_clone/network/api_service.dart';
import '../../../../trade/model/trade_account.dart';

abstract class InternalTransferEvent {}

class InitiateInternalTransfer extends InternalTransferEvent {
  final Account sourceAccount;
  final Account destinationAccount;
  final double amount;
  final String remark;

  InitiateInternalTransfer({
    required this.sourceAccount,
    required this.destinationAccount,
    required this.amount,
    required this.remark,
  });
}

class ResetInternalTransfer extends InternalTransferEvent {}

abstract class InternalTransferState {}

class InternalTransferInitial extends InternalTransferState {}

class InternalTransferLoading extends InternalTransferState {}

class InternalTransferSuccess extends InternalTransferState {
  final String message;
  final String transactionId;
  final double sourceClosingBalance;
  final double destinationClosingBalance;

  InternalTransferSuccess({
    required this.message,
    required this.transactionId,
    required this.sourceClosingBalance,
    required this.destinationClosingBalance,
  });
}

class InternalTransferError extends InternalTransferState {
  final String message;

  InternalTransferError({required this.message});
}

class InternalTransferBloc extends Bloc<InternalTransferEvent, InternalTransferState> {
  InternalTransferBloc() : super(InternalTransferInitial()) {
    on<InitiateInternalTransfer>(_onInitiateInternalTransfer);
    on<ResetInternalTransfer>(_onResetInternalTransfer);
  }

  Future<void> _onInitiateInternalTransfer(
      InitiateInternalTransfer event,
      Emitter<InternalTransferState> emit,
      ) async {
    try {
      emit(InternalTransferLoading());

      debugPrint("[Internal Transfer BLoC] 🔄 Initiating transfer...");

      final body = {
        "sourceAccountId": event.sourceAccount.accountId,
        "destinationAccountId": event.destinationAccount.accountId,
        "amount": event.amount,
        "remark": event.remark.isEmpty ? "Internal transfer" : event.remark,
      };

      debugPrint("[Internal Transfer BLoC] 📤 Sending body: $body");

      final response = await ApiService.internalTransfer(body);

      debugPrint("[Internal Transfer BLoC] ✅ Response received: ${response.toString()}");

      if (response.success) {
        debugPrint("[Internal Transfer BLoC] 🎉 Transfer successful");

        final data = response.data;
        final transactionId = data?['transactionId'] ?? '';
        final sourceClosingBalance = (data?['sourceClosingBalance'] ?? 0).toDouble();
        final destinationClosingBalance = (data?['destinationClosingBalance'] ?? 0).toDouble();

        emit(InternalTransferSuccess(
          message: response.message ?? "Transfer completed successfully",
          transactionId: transactionId,
          sourceClosingBalance: sourceClosingBalance,
          destinationClosingBalance: destinationClosingBalance,
        ));
      } else {
        debugPrint("[Internal Transfer BLoC] ⚠️ Transfer failed: ${response.message}");
        emit(InternalTransferError(
          message: response.message ?? "Transfer failed",
        ));
      }
    } catch (e, stackTrace) {
      debugPrint("[Internal Transfer BLoC] ❌ Exception during transfer: $e");
      debugPrint("[Internal Transfer BLoC] 🧵 Stack trace: $stackTrace");
      emit(InternalTransferError(
        message: "An error occurred during transfer. Please try again.",
      ));
    }
  }

  void _onResetInternalTransfer(
      ResetInternalTransfer event,
      Emitter<InternalTransferState> emit,
      ) {
    emit(InternalTransferInitial());
  }
}
