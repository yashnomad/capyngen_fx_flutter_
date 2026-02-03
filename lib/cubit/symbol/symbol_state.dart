// symbol_state.dart
import '../../models/symbol_model.dart';

class SymbolState {
  final bool isSymbolsLoading;
  final bool isWatchlistLoading;
  final Map<String, List<SymbolModel>> groupedSymbols;
  final List<String> categories;
  final List<WatchlistModel> watchlist;
  final String? errorMessage;

  SymbolState({
    this.isSymbolsLoading = false,
    this.isWatchlistLoading = false,
    this.groupedSymbols = const {},
    this.categories = const [],
    this.watchlist = const [],
    this.errorMessage,
  });

  // Factory for initial state
  factory SymbolState.initial() {
    return SymbolState(
      isSymbolsLoading: false,
      isWatchlistLoading: false,
      groupedSymbols: {},
      categories: [],
      watchlist: [],
      errorMessage: null,
    );
  }

  // CopyWith for partial updates
  SymbolState copyWith({
    bool? isSymbolsLoading,
    bool? isWatchlistLoading,
    Map<String, List<SymbolModel>>? groupedSymbols,
    List<String>? categories,
    List<WatchlistModel>? watchlist,
    String? errorMessage,
  }) {
    return SymbolState(
      isSymbolsLoading: isSymbolsLoading ?? this.isSymbolsLoading,
      isWatchlistLoading: isWatchlistLoading ?? this.isWatchlistLoading,
      groupedSymbols: groupedSymbols ?? this.groupedSymbols,
      categories: categories ?? this.categories,
      watchlist: watchlist ?? this.watchlist,
      errorMessage: errorMessage,
    );
  }
}
