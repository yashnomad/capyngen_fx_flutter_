import 'dart:convert';
import 'package:exness_clone/services/data_feed_ws.dart';
import 'package:exness_clone/view/auth_screen/login/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

import '../view/trade/model/trade_account.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_model';
  static const _keySymbols = 'cached_symbols';

  static const _keyLiveData = 'cached_live_data';


  // static const _keySelectedAccount = 'selected_account';

  static const _keyAppPin = 'app_encrypted_pin';

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() => _prefs.getString(_keyToken);

  static Future<void> deleteToken() async {
    await _prefs.remove(_keyToken);
  }

  static Future<void> saveUser(User user) async {
    final jsonString = jsonEncode(user.toJson());
    await _prefs.setString(_keyUser, jsonString);
  }

  static User? getUser() {
    final jsonString = _prefs.getString(_keyUser);
    if (jsonString == null) return null;
    return User.fromJson(jsonDecode(jsonString));
  }

  static Future<void> deleteUser() async {
    await _prefs.remove(_keyUser);
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static List<String>? getCachedSymbols() {
    return _prefs.getStringList(_keySymbols);
  }

  static Future<void> saveCachedSymbols(List<String> symbols) async {
    await _prefs.setStringList(_keySymbols, symbols);
  }

  static Future<void> clearCachedSymbols() async {
    await _prefs.remove(_keySymbols);
  }

  // static Future<void> saveSelectedAccount(Account account) async {
  //   final jsonString = jsonEncode(account.toJson());
  //   await _prefs.setString(_keySelectedAccount, jsonString);
  // }
  //
  // static Account? getSelectedAccount() {
  //   final jsonString = _prefs.getString(_keySelectedAccount);
  //   if (jsonString == null) return null;
  //   return Account.fromJson(jsonDecode(jsonString));
  // }
  //
  // static Future<void> deleteSelectedAccount() async {
  //   await _prefs.remove(_keySelectedAccount);
  // }

  static String encryptPin(String pin) {
    final bytes = utf8.encode('${pin}app_secret_pin');
    // final bytes = utf8.encode('${pin}app_secret_salt_key_2024');
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static Future<void> saveAppPin(String encryptedPin) async {
    await _prefs.setString(_keyAppPin, encryptedPin);
  }

  static String? getAppPin() {
    return _prefs.getString(_keyAppPin);
  }

  static Future<void> deleteAppPin() async {
    await _prefs.remove(_keyAppPin);
  }

  static bool hasAppPin() {
    return _prefs.containsKey(_keyAppPin);
  }


// Save live data when market is active
//   static Future<void> saveLiveData(List<LiveProfit> data) async {
//     final jsonList = data.map((e) => {
//       'symbol': e.symbol,
//       'ask': e.ask,
//       'bid': e.bid,
//     }).toList();
//     await _prefs.setString(_keyLiveData, jsonEncode(jsonList));
//   }
//
// // Get cached live data when market is closed
//   static List<LiveProfit>? getCachedLiveData() {
//     final jsonString = _prefs.getString(_keyLiveData);
//     if (jsonString == null) return null;
//
//     final List<dynamic> jsonList = jsonDecode(jsonString);
//     return jsonList.map((json) => LiveProfit.fromJson(json)).toList();
//   }

  static Future<void> clearExceptPin() async {
    final pin = _prefs.getString(_keyAppPin); // keep the pin

    await _prefs.clear(); // clear everything

    if (pin != null) {
      // restore the pin back
      await _prefs.setString(_keyAppPin, pin);
    }
  }


  static const _keySelectedAccount = 'selected_account';

  static Future<void> saveSelectedAccount(Account account) async {
    final jsonString = jsonEncode(account.toJson());
    await _prefs.setString(_keySelectedAccount, jsonString);
  }

  static Account? getSelectedAccount() {
    final jsonString = _prefs.getString(_keySelectedAccount);
    if (jsonString == null) return null;
    return Account.fromJson(jsonDecode(jsonString));
  }

  static Future<void> deleteSelectedAccount() async {
    await _prefs.remove(_keySelectedAccount);
  }


}
