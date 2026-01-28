/*
class SymbolModel {
  final String id;
  final String symbolName;
  final String cleanedName;

  SymbolModel({
    required this.id,
    required this.symbolName,
    required this.cleanedName,
  });

  factory SymbolModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['symbol_name']?.toString() ?? '';
    final cleaned = rawName.replaceAll(RegExp(r'^[A-Z]+:'), '');
    return SymbolModel(
      id: json['_id'] ?? '',
      symbolName: rawName,
      cleanedName: cleaned,
    );
  }
}
*/


class SymbolModel {
  final String id;
  final String symbolName;
  final String market;
  final String type;

  SymbolModel({required this.id, required this.symbolName, required this.market, required this.type});

  factory SymbolModel.fromJson(Map<String, dynamic> json) {
    return SymbolModel(
      id: json['_id'] ?? '',
      symbolName: json['symbol_name'] ?? '',
      market: json['market'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class WatchlistModel {
  final String id;
  final String symbolId;
  final String symbolName;

  WatchlistModel({required this.id, required this.symbolId, required this.symbolName});

  factory WatchlistModel.fromJson(Map<String, dynamic> json) {
    return WatchlistModel(
      id: json['_id'] ?? '',
      symbolId: json['symbol_id'] ?? '',
      symbolName: json['symbol_name'] ?? '',
    );
  }
}