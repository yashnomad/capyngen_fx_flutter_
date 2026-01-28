import 'package:flutter/foundation.dart';
import '../network/api_service.dart';
import '../models/symbol_model.dart';

class SymbolService {
  static Future<List<SymbolModel>> fetchSymbols() async {
    debugPrint('Fetching symbols from API...');
    final response = await ApiService.getAllSymbols();

    if (response.success && response.data != null) {
      final results = response.data!['results'] as List<dynamic>? ?? [];
      final symbols =
          results.map((item) => SymbolModel.fromJson(item)).toList();
      debugPrint('Fetched ${symbols.length} symbols.');
      return symbols;
    } else {
      debugPrint('API call failed or data is null.');
      return [];
    }
  }

  /// Fetch only these 3 for your current UI (GBPUSD, EURUSD, XAUUSD)
  // static Future<List<SymbolModel>> fetchTopSymbols() async {
  //   final all = await fetchSymbols();
  //   final filtered = all
  //       .where((s) =>
  //           s.cleanedName == 'GBPUSD' ||
  //           s.cleanedName == 'EURUSD' ||
  //           s.cleanedName == 'XAUUSD')
  //       .toList();
  //
  //   // debugPrint('Filtered symbols: ${filtered.map((e) => e.cleanedName)}');
  //   return filtered;
  // }
}
