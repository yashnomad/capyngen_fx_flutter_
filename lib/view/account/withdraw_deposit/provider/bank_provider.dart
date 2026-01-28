import 'package:flutter/foundation.dart';
import '../../../../../network/api_service.dart';
import '../../../../../utils/snack_bar.dart';
import '../model/bank_model.dart';

class DepositController extends ChangeNotifier {
  List<Result> accounts = [];
  Result? selected;
  bool isLoading = false;

  Future<void> loadAccounts() async {
    isLoading = true;
    notifyListeners();

    final response = await ApiService.accountList();

    if (response.success && response.data != null) {
      final parsed = BankAccountModel.fromJson(response.data!);

      final filtered = parsed.results
          .where((e) => e.status.trim().toLowerCase() == 'active')
          .toList();

      accounts = filtered;
      selected = filtered.isNotEmpty ? filtered.first : null;
    } else {
      SnackBarService.showError('Failed to load bank accounts');
    }

    isLoading = false;
    notifyListeners();
  }

  void changeAccount(Result model) {
    selected = model;
    notifyListeners();
  }
}
