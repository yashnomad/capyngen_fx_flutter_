import 'package:flutter/foundation.dart';

class BottomNavHelper {
  static final ValueNotifier<int> indexNotifier = ValueNotifier<int>(0);

  static void goTo(int newIndex) {
    indexNotifier.value = newIndex;
  }
}

