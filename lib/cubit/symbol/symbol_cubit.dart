
// symbol_cubit.dart
import 'package:exness_clone/cubit/symbol/symbol_state.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/symbol_model.dart';
import '../../network/api_service.dart';

class SymbolCubit extends Cubit<SymbolState> {
  SymbolCubit() : super(SymbolState.initial());

  Future<void> getAllSymbols() async {
    emit(state.copyWith(isSymbolsLoading: true));

    try {
      final response = await ApiService.getAllSymbols();

      if (response.success && response.data != null) {
        final List rawList = response.data!['results'] ?? [];
        final symbols = rawList.map((e) => SymbolModel.fromJson(e)).toList();

        // 1. DYNAMIC GROUPING
        final Map<String, List<SymbolModel>> grouped = {};

        for (var item in symbols) {
          // Use 'type' from API as the category name
          // We use toUpperCase() to ensure "Forex" and "FOREX" don't create two groups
          final category = item.market.toUpperCase();

          if (!grouped.containsKey(category)) {
            grouped[category] = [];
          }
          grouped[category]!.add(item);
        }

        // 2. EXTRACT CATEGORIES
        // This list is now created based on actual data, not hardcoded strings
        final dynamicCategories = grouped.keys.toList();

        // Optional: Sort them alphabetically so they don't jump around
        // dynamicCategories.sort();

        emit(state.copyWith(
          isSymbolsLoading: false,
          groupedSymbols: grouped,
          categories: dynamicCategories,
        ));
      } else {
        emit(state.copyWith(
          isSymbolsLoading: false,
          errorMessage: response.message ?? "Failed to fetch symbols",
        ));
      }
    } catch (e) {
      emit(state.copyWith(isSymbolsLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> getWatchList(String userId) async {
    // Note: We don't check if empty here because user might have switched accounts
    // and we need to refresh the list for the NEW user.
    emit(state.copyWith(isWatchlistLoading: true));

    try {
      final response =
          await ApiService.getWatchListSymbols(userId); // Use userId here

      if (response.success && response.data != null) {
        final List rawList = response.data!['data'] ?? [];
        final list = rawList.map((e) => WatchlistModel.fromJson(e)).toList();

        emit(state.copyWith(
          isWatchlistLoading: false,
          watchlist: list,
        ));
      } else {
        emit(state.copyWith(
            isWatchlistLoading: false, errorMessage: response.message));
      }
    } catch (e) {
      emit(state.copyWith(
          isWatchlistLoading: false, errorMessage: e.toString()));
    }
  }

  // 3. Add to Watchlist
  Future<void> addToWatchlist(String symbolId, String tradeUserId) async {
    try {
      final Map<String, dynamic> payload = {
        "symbol_id": symbolId,
        "trade_user_id": tradeUserId
      };

      final response = await ApiService.addSymbols(payload);

      if (response.success) {
        SnackBarService.showSuccess(response.message ?? 'Added Successfully');

        await getWatchList(tradeUserId);
      } else {
        SnackBarService.showError("Add failed: ${response.message}");
      }
    } catch (e) {
      SnackBarService.showError("Add Error: $e");
    }
  }

  Future<void> removeFromWatchlist(
      String watchlistId, String tradeUserId) async {
    // 1. Snapshot the current list (in case we need to undo)
    final previousList = List<WatchlistModel>.from(state.watchlist);

    // 2. OPTIMISTIC UPDATE: Remove locally immediately
    // This satisfies the Dismissible widget instantly
    final updatedList =
        state.watchlist.where((item) => item.id != watchlistId).toList();

    emit(state.copyWith(
      watchlist: updatedList,
      // Do NOT set loading=true here, or it will rebuild the whole list
      // and kill the remove animation.
    ));

    try {
      // 3. Perform the actual API call in background
      final response = await ApiService.removeSymbol(watchlistId);

      if (response.success) {
        SnackBarService.showSuccess("Removed successfully");
        // Optional: You can fetch the fresh list silently if you want to be sure
        // await getWatchList(tradeUserId);
      } else {
        // 4. API FAILURE: Revert the change (Put the item back)
        emit(state.copyWith(watchlist: previousList));
        SnackBarService.showError("Remove failed: ${response.message}");
      }
    } catch (e) {
      // 5. NETWORK ERROR: Revert the change
      emit(state.copyWith(watchlist: previousList));
      SnackBarService.showError("Connection error: Item restored");
    }
  }

}
