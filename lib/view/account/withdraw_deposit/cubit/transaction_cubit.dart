import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/foundation.dart';
import '../../../../network/api_service.dart';
import '../../../trade/model/trade_account.dart';
import '../model/bank_model.dart';
part 'transaction_state.dart';

enum DepositMethod { bankTransfer, upi, crypto }

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());
  Future<void> depositFunds({
    required Account tradingAccount,
    required double amount,
    required DepositMethod paymentMode,
    String? gatewayName,
    String? merchantId,
    String? utrNumber,
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = tradingAccount.id;
      if (tradeUserId == null || amount <= 0) {
        emit(const TransactionFailure("Invalid account or amount"));
        return;
      }

      // Initialize body with mandatory fields
      final Map<String, dynamic> body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      switch (paymentMode) {
        case DepositMethod.bankTransfer:
          body.addAll({
            "payment_mode": "bank_transfer",
            "merchant_id": merchantId?.toString(), // Ensure String type
            "utr_number": utrNumber,
          });
          break;

        case DepositMethod.upi:
          body.addAll({
            "payment_mode": "UPI",
            "merchant_id": merchantId?.toString(), // Ensure String type
            "utr_number": utrNumber,
          });
          break;

        case DepositMethod.crypto:
          final effectiveGateway = gatewayName ?? "online";
          body.addAll({
            "payment_mode": "Crypto",
            "gateway_name": effectiveGateway,
          });

          // Backend requires merchant_id and utr_number for manual crypto
          if (effectiveGateway == "manual") {
            if (merchantId == null || merchantId.isEmpty) {
              emit(const TransactionFailure("Please select a crypto wallet"));
              return;
            }
            body.addAll({
              "merchant_id": merchantId.toString(),
              "utr_number": utrNumber,
            });
          }
          break;
      }


      final response = await ApiService.deposit(body);

      if (response.success) {
        if (paymentMode == DepositMethod.crypto && (gatewayName ?? "online") == "online") {
          final paymentLink = response.data?['payment_link'];
          if (paymentLink != null && paymentLink['url'] != null) {
            emit(TransactionSuccessCrypto(
              paymentUrl: paymentLink['url'],
              cryptoId: paymentLink['payRef'] ?? "",
            ));
            return;
          }
        }
        emit(TransactionSuccess(response.message ?? "Deposit request sent"));
      } else {
        emit(TransactionFailure(response.message ?? "Deposit failed"));
      }
    } catch (e) {
      debugPrint("❌ Deposit Error: $e");
      emit(TransactionFailure("An error occurred: $e"));
    }
  }

  Future<void> depositDemoFunds({
    required Account tradingAccount,
    double amount = 10000,
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = tradingAccount.id;
      if (tradeUserId == null) {
        emit(TransactionFailure("Invalid demo account"));
        return;
      }

      final body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      final response = await ApiService.demoDeposit(body, tradeUserId);

      if (response.success) {
        emit(TransactionSuccess("Demo balance added"));
      } else {
        emit(TransactionFailure(response.message ?? "Demo deposit failed"));
      }
    } catch (e) {
      emit(TransactionFailure("Error: $e"));
    }
  }

  Future<void> withdrawFunds({
    required Account account,
    required double amount,
    required String method,
    String? destinationAddress,
    String? upiId, // For UPI
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = account.id;

      if (tradeUserId == null || amount <= 0) {
        emit(const TransactionFailure("Invalid account or amount"));
        return;
      }

      // Base body
      final Map<String, dynamic> body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
        "method": method,
      };

      // Add specific details based on method
      if (method == 'crypto') {
        if (destinationAddress == null || destinationAddress.isEmpty) {
          emit(const TransactionFailure(
              "Wallet address is required for Crypto withdrawal"));
          return;
        }
        body['wallet_address'] = destinationAddress;
      } else if (method == 'upi') {
        if (upiId == null || upiId.isEmpty) {
          emit(const TransactionFailure("UPI ID is required"));
          return;
        }
        body['upi_id'] = upiId;
      }

      debugPrint("[Withdraw] 📤 Sending body: $body");
      final response = await ApiService.withdraw(body);
      debugPrint("[Withdraw] ✅ Response received: ${response.toString()}");

      if (response.success) {
        String successMessage =
            response.message ?? "Withdraw request submitted";

        // Parse response data for a more detailed message (Transaction ID)
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final result = data['result'] as Map<String, dynamic>?;
          final status = result?['status'] ?? "unknown";
          final txnId = result?['transactionId'] ?? "N/A";
          successMessage = "Withdrawal $status (Txn: $txnId)";
        }

        emit(TransactionSuccess(successMessage));
      } else {
        emit(TransactionFailure(response.message ?? "Withdrawal failed"));
      }
    } catch (e, stackTrace) {
      debugPrint("[Withdraw] ❌ Exception during withdrawal: $e\n$stackTrace");
      emit(TransactionFailure("An error occurred: $e"));
    }
  }
}
/*
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/foundation.dart';
import '../../../../network/api_service.dart';
import '../../../trade/model/trade_account.dart';
import '../model/bank_model.dart';
part 'transaction_state.dart';

enum DepositMethod { bankTransfer, upi, crypto }

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());

  Future<void> depositFunds({
    required Account tradingAccount,
    required double amount,

    // FROM UI
    required DepositMethod paymentMode,
    String? gatewayName, // "online" | "manual" (Crypto only)
    String? merchantId,  // Bank / UPI / Crypto(manual)
    String? utrNumber,   // Bank / Crypto(manual)
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = tradingAccount.id;

      if (tradeUserId == null || amount <= 0) {
        emit(TransactionFailure("Invalid account or amount"));
        return;
      }

      /// BASE PAYLOAD (COMMON)
      final Map<String, dynamic> body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      /// PAYMENT MODE HANDLING (JOI SAFE)
      switch (paymentMode) {
      // ================= BANK TRANSFER =================
        case DepositMethod.bankTransfer:
          if (merchantId == null || merchantId.isEmpty) {
            emit(TransactionFailure("Merchant ID is required"));
            return;
          }
          if (utrNumber == null || utrNumber.isEmpty) {
            emit(TransactionFailure("UTR number is required"));
            return;
          }

          body.addAll({
            "payment_mode": "bank_transfer",
            "merchant_id": merchantId,
            "utr_number": utrNumber,
          });
          break;

      // ================= UPI =================
        case DepositMethod.upi:
          if (merchantId == null || merchantId.isEmpty) {
            emit(TransactionFailure("Merchant ID is required"));
            return;
          }
          if (utrNumber == null || utrNumber.isEmpty) {
            emit(TransactionFailure("UTR number is required"));
            return;
          }

          body.addAll({
            "payment_mode": "UPI",
            "merchant_id": merchantId,
            "utr_number": utrNumber,
          });
          break;

      // ================= CRYPTO =================
        case DepositMethod.crypto:
          if (gatewayName == null ||
              (gatewayName != "online" && gatewayName != "manual")) {
            emit(TransactionFailure(
                "Invalid gateway. Use online or manual"));
            return;
          }

          body.addAll({
            "payment_mode": "Crypto",
            "gateway_name": gatewayName,
          });

          // EXTRA REQUIREMENTS FOR MANUAL CRYPTO
          if (gatewayName == "manual") {
            if (merchantId == null || merchantId.isEmpty) {
              emit(TransactionFailure(
                  "Merchant ID required for manual crypto"));
              return;
            }
            if (utrNumber == null || utrNumber.isEmpty) {
              emit(TransactionFailure(
                  "UTR number required for manual crypto"));
              return;
            }

            body.addAll({
              "merchant_id": merchantId,
              "utr_number": utrNumber,
            });
          }
          break;
      }

      debugPrint("📤 Deposit Payload: $body");

      final response = await ApiService.deposit(body);

      if (!response.success) {
        emit(TransactionFailure(response.message ?? "Deposit failed"));
        return;
      }

      /// CRYPTO SPECIAL RESPONSE
      if (paymentMode == DepositMethod.crypto) {
        final paymentLink = response.data?['payment_link'];

        if (paymentLink == null ||
            paymentLink['url'] == null ||
            paymentLink['payRef'] == null) {
          emit(TransactionFailure("Invalid crypto payment response"));
          return;
        }

        emit(
          TransactionSuccessCrypto(
            paymentUrl: paymentLink['url'],
            cryptoId: paymentLink['payRef'],
          ),
        );
        return;
      }

      /// BANK / UPI SUCCESS
      emit(TransactionSuccess(response.message ?? "Deposit request sent"));
    } catch (e, stackTrace) {
      debugPrint("❌ depositFunds error: $e\n$stackTrace");
      emit(TransactionFailure("Something went wrong"));
    }
  }


  */
/*Future<void> depositFunds({
    required Account tradingAccount,
    required Result account,
    required double amount,
    required DepositMethod method,
    String? utrNumber, // For bank transfer
    String? merchantId, // From bank list
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = tradingAccount.id;

      if (tradeUserId == null || amount <= 0) {
        emit(TransactionFailure("Invalid account or amount"));
        return;
      }

      Map<String, dynamic> body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      switch (method) {
        case DepositMethod.bankTransfer:
          if (merchantId == null || merchantId.isEmpty) {
            emit(TransactionFailure("Merchant bank account is missing"));
            return;
          }

          if (utrNumber == null || utrNumber.isEmpty) {
            emit(TransactionFailure("Please enter UTR number"));
            return;
          }

          body.addAll({
            "payment_mode": "bank_transfer",
            // "payment_mode": "Bank Transfer",
            "merchant_id": merchantId,
            "utr_number": utrNumber,
          });
          break;

        case DepositMethod.upi:
          if (merchantId == null || merchantId.isEmpty) {
            emit(TransactionFailure("Merchant bank account is missing"));
            return;
          }

          if (utrNumber == null || utrNumber.isEmpty) {
            emit(TransactionFailure("Please enter UTR number"));
            return;
          }
          body.addAll({
            "payment_mode": "UPI",
            "merchant_id": merchantId,
            "utr_number": utrNumber,
          });
          break;

        case DepositMethod.crypto:
          body.addAll({"payment_mode": "Crypto"});
          break;
      }

      final response = await ApiService.deposit(body);

      if (response.success) {
        // CRYPTO SPECIAL HANDLING
        if (method == DepositMethod.crypto) {
          final paymentLink = response.data?['payment_link'];

          if (paymentLink != null &&
              paymentLink['url'] != null &&
              paymentLink['payRef'] != null) {
            emit(
              TransactionSuccessCrypto(
                paymentUrl: paymentLink['url'],
                cryptoId: paymentLink['payRef'],
              ),
            );
            return;
          }

          emit(TransactionFailure("Invalid crypto payment response"));
          return;
        }

        // NORMAL SUCCESS STATE (UPI / BANK)
        SnackBarService.showSuccess(response.message ?? 'Deposit request sent');

        emit(
          TransactionSuccess(response.message ?? "Deposit request sent"),
        );
      } else {
        SnackBarService.showError(response.message ?? "Deposit failed");
        emit(TransactionFailure(response.message ?? "Deposit failed"));
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error in depositFunds: $e\n$stackTrace");
      emit(TransactionFailure("An error occurred: $e"));
    }
  }*/ /*



  Future<void> depositDemoFunds({
    required Account tradingAccount,
    double amount = 10000,
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = tradingAccount.id;
      if (tradeUserId == null) {
        emit(TransactionFailure("Invalid demo account"));
        return;
      }

      final body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
      };

      final response = await ApiService.demoDeposit(body, tradeUserId);

      if (response.success) {
        emit(TransactionSuccess("Demo balance added"));
      } else {
        emit(TransactionFailure(response.message ?? "Demo deposit failed"));
      }
    } catch (e) {
      emit(TransactionFailure("Error: $e"));
    }
  }

  Future<void> withdrawFunds({
    required Account account,
    required double amount,
    required String method, // 'bank', 'upi', or 'crypto'
    String? destinationAddress, // For Crypto
    String? upiId, // For UPI
  }) async {
    emit(TransactionLoading());

    try {
      final tradeUserId = account.id;

      if (tradeUserId == null || amount <= 0) {
        emit(const TransactionFailure("Invalid account or amount"));
        return;
      }

      // Base body
      final Map<String, dynamic> body = {
        "trade_user_id": tradeUserId,
        "amount": amount,
        "method": method,
      };

      // Add specific details based on method
      if (method == 'crypto') {
        if (destinationAddress == null || destinationAddress.isEmpty) {
          emit(const TransactionFailure(
              "Wallet address is required for Crypto withdrawal"));
          return;
        }
        body['wallet_address'] = destinationAddress;
      } else if (method == 'upi') {
        if (upiId == null || upiId.isEmpty) {
          emit(const TransactionFailure("UPI ID is required"));
          return;
        }
        body['upi_id'] = upiId;
      }

      debugPrint("[Withdraw] 📤 Sending body: $body");
      final response = await ApiService.withdraw(body);
      debugPrint("[Withdraw] ✅ Response received: ${response.toString()}");

      if (response.success) {
        String successMessage =
            response.message ?? "Withdraw request submitted";

        // Parse response data for a more detailed message (Transaction ID)
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final result = data['result'] as Map<String, dynamic>?;
          final status = result?['status'] ?? "unknown";
          final txnId = result?['transactionId'] ?? "N/A";
          successMessage = "Withdrawal $status (Txn: $txnId)";
        }

        emit(TransactionSuccess(successMessage));
      } else {
        emit(TransactionFailure(response.message ?? "Withdrawal failed"));
      }
    } catch (e, stackTrace) {
      debugPrint("[Withdraw] ❌ Exception during withdrawal: $e\n$stackTrace");
      emit(TransactionFailure("An error occurred: $e"));
    }
  }
}
*/
