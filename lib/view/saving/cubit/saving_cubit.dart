import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../network/api_service.dart';
import '../../../services/storage_service.dart';
import '../model/investment_model.dart';
import '../model/saving_model.dart';

abstract class SavingState {}

class SavingInitial extends SavingState {}

class SavingLoading extends SavingState {}

class SavingLoaded extends SavingState {
  final List<SavingPackage> packages;
  final List<UserInvestment> myInvestments;
  SavingLoaded({required this.packages, required this.myInvestments});
}

class SavingError extends SavingState {
  final String message;
  SavingError(this.message);
}

class SavingCubit extends Cubit<SavingState> {
  // Hardcoded ID from your curl command example
  SavingCubit() : super(SavingInitial());

  String? get tradeUserId => StorageService.getSelectedAccount()?.id;

  // 1. Fetch Data (Uses API: package & getInvestment)
  Future<void> loadPageData() async {
    emit(SavingLoading());
    try {
      if (tradeUserId == null) {
        emit(SavingError("Trade User ID not found in local storage"));
        return;
      }
      // Call both GET APIs in parallel
      final results = await Future.wait([
        ApiService.package(), // API 1
        ApiService.getInvestment(tradeUserId!) // API 2
      ]);

      // Parse Packages (API 1 Result)
      final packageRes = results[0];
      List<SavingPackage> packages = [];
      if (packageRes.data != null && packageRes.data!['results'] != null) {
        packages = (packageRes.data!['results'] as List)
            .map((e) => SavingPackage.fromJson(e))
            .toList();
      }

      // Parse Investments (API 2 Result)
      final investRes = results[1];
      List<UserInvestment> investments = [];
      if (investRes.data != null && investRes.data!['results'] != null) {
        investments = (investRes.data!['results'] as List)
            .map((e) => UserInvestment.fromJson(e))
            .toList();
      }

      emit(SavingLoaded(packages: packages, myInvestments: investments));
    } catch (e) {
      emit(SavingError("Error loading data: $e"));
    }
  }

  // 2. Subscribe (Uses API: createInvestment)
  Future<void> subscribe(String packageId, num amount) async {
    try {
      if (tradeUserId == null) {
        emit(SavingError("Trade User ID not found in local storage"));
        return;
      }
      final body = {
        "packageId": packageId,
        "investedAmount": amount,
        "trade_user_id": tradeUserId
      };

      // API 3 Call
      final response = await ApiService.createInvestment(body);

      if (response.data != null && response.data!['success'] == true) {
        // Reload data to show the new investment in "My Savings"
        loadPageData();
      }
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }
}
