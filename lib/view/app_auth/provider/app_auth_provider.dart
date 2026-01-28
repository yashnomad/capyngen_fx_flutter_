import 'package:exness_clone/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

class AppAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _hasPinSet = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get hasPinSet => _hasPinSet;

  AppAuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _hasPinSet = StorageService.hasAppPin();
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> savePin(String pin) async {
    try {
      final encryptedPin = StorageService.encryptPin(pin);
      await StorageService.saveAppPin(encryptedPin);
      _hasPinSet = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = StorageService.getAppPin();
      if (storedPin == null) return false;

      final encryptedPin = StorageService.encryptPin(pin);
      return encryptedPin == storedPin;
    } catch (e) {
      return false;
    }
  }

  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> resetPin() async {
    await StorageService.deleteAppPin();
    _hasPinSet = false;
    _isAuthenticated = false;
    notifyListeners();
  }
}
