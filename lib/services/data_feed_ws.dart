import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:msgpack_dart/msgpack_dart.dart' as mp;

class DataFeedWS {
  DataFeedWS._();
  static final DataFeedWS _instance = DataFeedWS._();
  factory DataFeedWS() => _instance;

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String jwt,
    required String tradeUserId,
    required void Function(List<LiveProfit>) onLiveData,
    void Function(String)? onError,
    VoidCallback? onConnected,
  }) {
    if (isConnected) return;

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': jwt})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [Socket] Connected');

      if (tradeUserId.isNotEmpty) {
        debugPrint('📤 [Socket] Subscribing user: $tradeUserId');
        _socket!.emit('subscribe', tradeUserId);
        _socket!.emit('equity:value', tradeUserId);
      }

      onConnected?.call();
    });

    _socket!.on('live-data', (data) {
      try {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📩 WS live-data');
        debugPrint('🧠 RuntimeType: ${data.runtimeType}');

        Uint8List? bytes;

        // ✅ 1. Already-decoded payloads (JSON / Map)
        if (data is Map || data is String) {
          debugPrint('📝 Already decoded payload: $data');
          _processDecodedData(data, onLiveData);
          return;
        }

        // ✅ 2. Binary payloads (MessagePack)
        if (data is Uint8List) {
          bytes = data;
        } else if (data is ByteBuffer) {
          bytes = data.asUint8List();
        } else if (data is List<int>) {
          bytes = Uint8List.fromList(data);
        } else {
          debugPrint('⚠️ Unknown payload type ignored');
          return;
        }

        if (bytes.isEmpty) {
          debugPrint('⚠️ Empty binary payload');
          return;
        }

        debugPrint('📦 First 20 bytes: ${bytes.take(20).toList()}');

        // 🔑 Decode MessagePack safely
        dynamic decoded;
        try {
          decoded = mp.deserialize(bytes);
          debugPrint('✅ MessagePack decoded');
        } catch (e) {
          debugPrint('❌ MessagePack decode failed: $e');
          return;
        }

        debugPrint('📥 Decoded payload: $decoded');
        _processDecodedData(decoded, onLiveData);
      } catch (e, stackTrace) {
        debugPrint('❌ [Socket Error]: $e');
        debugPrint(stackTrace.toString());
        onError?.call(e.toString());
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('🔌 [Socket] Disconnected');
    });

    _socket!.onError((err) {
      debugPrint('❌ [Socket Error]: $err');
      onError?.call(err.toString());
    });
  }

  void _processDecodedData(
    dynamic data,
    void Function(List<LiveProfit>) callback,
  ) {
    // Helper to extract list regardless of structure
    List<dynamic> items = [];

    if (data is List) {
      items = data;
    } else if (data is Map) {
      items = [data];
    }

    final profits = <LiveProfit>[];

    for (var item in items) {
      if (item is Map) {
        // 1. Map Keys (Handle both short 's' and full 'symbol' keys just in case)
        final symbol =
            item['s']?.toString() ?? item['symbol']?.toString() ?? '';

        // 2. Parse Prices
        final ask = _parseDouble(item['a'] ?? item['ask']);
        final bid = _parseDouble(item['b'] ?? item['bid']);

        // 3. Parse Sizes (Volume) - seen in logs as 'as' and 'bs'
        final askSize = _parseDouble(item['as'] ?? item['askSize']);
        final bidSize = _parseDouble(item['bs'] ?? item['bidSize']);

        // 4. Parse Timestamp - seen in logs as 'dt'
        final int timestamp = (item['dt'] is int)
            ? item['dt']
            : int.tryParse(item['dt']?.toString() ?? '0') ?? 0;

        if (symbol.isNotEmpty) {
          profits.add(
            LiveProfit(
              symbol: symbol,
              ask: ask,
              bid: bid,
              askSize: askSize,
              bidSize: bidSize,
              timestamp: timestamp,
            ),
          );
        }
      }
    }

    if (profits.isNotEmpty) {
      // debugPrint('✅ Emitting ${profits.length} updates');
      callback(profits);
    }
  }

  // Your existing helper (Keep this, it's good)
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void subscribeSymbol(String symbolName) {
    if (_socket != null && _socket!.connected) {
      debugPrint('📤 [Socket] Subscribing symbol: $symbolName');
      _socket!.emit('live-data', symbolName);
    }
  }

  // ─────────────────────────────────────────────
  // 🔌 DISCONNECT
  // ─────────────────────────────────────────────
  void disconnect() {
    _socket?.disconnect();
    debugPrint('🔌 [Socket] Manually disconnected');
  }
}

class LiveProfit {
  final String symbol;
  final double ask;
  final double bid;
  final double askSize;
  final double bidSize;
  final int timestamp;

  LiveProfit({
    required this.symbol,
    required this.ask,
    required this.bid,
    this.askSize = 0.0,
    this.bidSize = 0.0,
    this.timestamp = 0,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  @override
  String toString() =>
      'LiveProfit($symbol | Ask: $ask (Vol: $askSize) | Bid: $bid (Vol: $bidSize) | Time: $timestamp)';
}

/* // Old version for reference
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:msgpack_dart/msgpack_dart.dart' as mp;


class DataFeedWS {
  DataFeedWS._();
  static final DataFeedWS _instance = DataFeedWS._();
  factory DataFeedWS() => _instance;

  io.Socket? _socket;
  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String jwt,
    required String tradeUserId,
    required void Function(List<LiveProfit>) onLiveData,
    void Function(String)? onError,
    VoidCallback? onConnected,
  }) {
    if (isConnected) return;

    _socket = io.io(
      'https://api.capyngen.us',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': jwt})
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('✅ [Socket] Connected!');
      if (tradeUserId.isNotEmpty) {
        debugPrint('📤 [Socket] Emitting subscribe: "$tradeUserId"');
        _socket!.emit("subscribe", tradeUserId);
        _socket!.emit("equity:value", tradeUserId);
      }
      onConnected?.call();
    });

    _socket!.on('live-data', (data) {
      try {
        // Convert incoming data to bytes
        Uint8List? bytes;

        if (data is List<int>) {
          bytes = Uint8List.fromList(data);
        } else if (data is ByteBuffer) {
          bytes = data.asUint8List();
        } else if (data is List && data.isNotEmpty) {
          if (data[0] is List<int>) {
            bytes = Uint8List.fromList(List<int>.from(data[0]));
          } else if (data[0] is int) {
            bytes = Uint8List.fromList(List<int>.from(data));
          }
        } else if (data is Map || data is String) {
          _processDecodedData(data, onLiveData);
          return;
        }

        if (bytes == null || bytes.isEmpty) {
          debugPrint('⚠️ [Socket] Received empty data');
          return;
        }

        // Log first few bytes for debugging
        debugPrint(
            '📦 [Raw bytes]: ${bytes.sublist(0, bytes.length > 20 ? 20 : bytes.length)}');

        // Try to decode - attempt multiple methods
        dynamic decodedData;

        // Method 1: Try UTF-8 JSON
        try {
          final jsonString = utf8.decode(bytes);
          decodedData = jsonDecode(jsonString);
          debugPrint('✅ [Decoded as JSON]');
        } catch (e) {
          // Method 2: Try MessagePack
          debugPrint('ℹ️ [Not JSON, trying MessagePack]');
          try {
            decodedData = _decodeMessagePack(bytes);
            debugPrint('✅ [Decoded as MessagePack]');
          } catch (e2) {
            debugPrint('❌ [MessagePack failed]: $e2');
            onError?.call('Failed to decode: $e2');
            return;
          }
        }

        if (decodedData != null) {
          debugPrint('📥 [Decoded data]: $decodedData');
          _processDecodedData(decodedData, onLiveData);
        }
      } catch (e, stackTrace) {
        debugPrint('❌ [Socket Error]: $e');
        debugPrint('Stack: $stackTrace');
        onError?.call(e.toString());
      }
    });

    _socket!.onDisconnect((_) => debugPrint('🔌 [Socket] Disconnected'));
    _socket!.onError((data) {
      debugPrint('❌ [Socket Error]: $data');
      onError?.call(data.toString());
    });
  }

  /// Decode MessagePack binary format
  dynamic _decodeMessagePack(Uint8List bytes) {
    final data = ByteData.view(bytes.buffer);
    int offset = 0;

    dynamic readValue() {
      if (offset >= bytes.length) return null;

      final byte = bytes[offset];
      offset++;

      // FixArray (0x90 - 0x9F): array with 0-15 elements
      if (byte >= 0x90 && byte <= 0x9F) {
        final size = byte & 0x0F;
        final list = [];
        for (int i = 0; i < size; i++) {
          list.add(readValue());
        }
        return list;
      }

      // FixMap (0x80 - 0x8F): map with 0-15 elements
      if (byte >= 0x80 && byte <= 0x8F) {
        final size = byte & 0x0F;
        final map = <String, dynamic>{};
        for (int i = 0; i < size; i++) {
          final key = readValue();
          final value = readValue();
          if (key != null) map[key.toString()] = value;
        }
        return map;
      }

      // Map16 (0xDE): map with 16-bit size
      if (byte == 0xDE) {
        final size = data.getUint16(offset, Endian.big);
        offset += 2;
        final map = <String, dynamic>{};
        for (int i = 0; i < size; i++) {
          final key = readValue();
          final value = readValue();
          if (key != null) map[key.toString()] = value;
        }
        return map;
      }

      // FixStr (0xA0 - 0xBF): string with 0-31 bytes
      if (byte >= 0xA0 && byte <= 0xBF) {
        final length = byte & 0x1F;
        final str = utf8.decode(bytes.sublist(offset, offset + length));
        offset += length;
        return str;
      }

      // Str8 (0xD9): string with 8-bit length
      if (byte == 0xD9) {
        final length = bytes[offset];
        offset++;
        final str = utf8.decode(bytes.sublist(offset, offset + length));
        offset += length;
        return str;
      }

      // Float64 (0xCB): 64-bit float
      if (byte == 0xCB) {
        final value = data.getFloat64(offset, Endian.big);
        offset += 8;
        return value;
      }

      // Float32 (0xCA): 32-bit float
      if (byte == 0xCA) {
        final value = data.getFloat32(offset, Endian.big);
        offset += 4;
        return value;
      }

      // Positive FixInt (0x00 - 0x7F)
      if (byte <= 0x7F) {
        return byte;
      }

      // Negative FixInt (0xE0 - 0xFF)
      if (byte >= 0xE0) {
        return byte - 256;
      }

      // Int8 (0xD0)
      if (byte == 0xD0) {
        final value = data.getInt8(offset);
        offset++;
        return value;
      }

      // Int16 (0xD1)
      if (byte == 0xD1) {
        final value = data.getInt16(offset, Endian.big);
        offset += 2;
        return value;
      }

      // Int32 (0xD2)
      if (byte == 0xD2) {
        final value = data.getInt32(offset, Endian.big);
        offset += 4;
        return value;
      }

      // UInt8 (0xCC)
      if (byte == 0xCC) {
        final value = bytes[offset];
        offset++;
        return value;
      }

      // UInt16 (0xCD)
      if (byte == 0xCD) {
        final value = data.getUint16(offset, Endian.big);
        offset += 2;
        return value;
      }

      // Nil (0xC0)
      if (byte == 0xC0) return null;

      // Boolean false (0xC2)
      if (byte == 0xC2) return false;

      // Boolean true (0xC3)
      if (byte == 0xC3) return true;

      debugPrint('⚠️ [Unknown MessagePack type]: 0x${byte.toRadixString(16)}');
      return null;
    }

    return readValue();
  }

  /// Process decoded data
  void _processDecodedData(dynamic data, Function(List<LiveProfit>) callback) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('_placeholder')) return;

      final symbol = data['symbol']?.toString() ?? data['s']?.toString() ?? '';
      final ask = _parseDouble(data['ask'] ?? data['a']);
      final bid = _parseDouble(data['bid'] ?? data['b']);

      if (symbol.isNotEmpty && (ask > 0 || bid > 0)) {
        debugPrint('✅ [Parsed] Symbol: $symbol, Ask: $ask, Bid: $bid');
        callback([LiveProfit(symbol: symbol, ask: ask, bid: bid)]);
      } else {
        debugPrint('⚠️ [Invalid Data] Symbol: $symbol, Ask: $ask, Bid: $bid');
      }
    } else if (data is List) {
      // Handle array of maps OR nested array structure
      final profits = <LiveProfit>[];
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          // Standard map format: {s: "AUDCHF", a: 0.123, b: 0.456}
          final symbol =
              item['symbol']?.toString() ?? item['s']?.toString() ?? '';
          final ask = _parseDouble(item['ask'] ?? item['a']);
          final bid = _parseDouble(item['bid'] ?? item['b']);

          if (symbol.isNotEmpty && (ask > 0 || bid > 0)) {
            profits.add(LiveProfit(symbol: symbol, ask: ask, bid: bid));
          }
        } else if (item is List && item.length >= 3) {
          // Handle nested array format: [[{...}, {...}, {...}], ...]
          // Each item in the outer array might be another array with map data
          for (var innerItem in item) {
            if (innerItem is Map<String, dynamic>) {
              final symbol = innerItem['symbol']?.toString() ??
                  innerItem['s']?.toString() ??
                  '';
              final ask = _parseDouble(innerItem['ask'] ?? innerItem['a']);
              final bid = _parseDouble(innerItem['bid'] ?? innerItem['b']);

              if (symbol.isNotEmpty && (ask > 0 || bid > 0)) {
                profits.add(LiveProfit(symbol: symbol, ask: ask, bid: bid));
              }
            }
          }
        }
      }
      if (profits.isNotEmpty) {
        callback(profits);
      }
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  void subscribeSymbol(String symbolName) {
    if (_socket != null && _socket!.connected) {
      debugPrint('📤 [Socket] Subscribing to: $symbolName');
      _socket!.emit("live-data", symbolName);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    debugPrint('🔌 [Socket] Manually disconnected');
  }
}

class LiveProfit {
  final String symbol;
  final double ask;
  final double bid;

  LiveProfit({
    required this.symbol,
    required this.ask,
    required this.bid,
  });

  @override
  String toString() => 'LiveProfit(symbol: $symbol, ask: $ask, bid: $bid)';
}
*/
