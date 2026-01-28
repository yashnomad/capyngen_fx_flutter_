import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    debugPrint(
        '🟢 ${bloc.runtimeType} created bloc→ ${identityHashCode(bloc)}');
    super.onCreate(bloc);
  }

  @override
  void onClose(BlocBase bloc) {
    debugPrint('🔴 ${bloc.runtimeType} closed → ${identityHashCode(bloc)}');
    super.onClose(bloc);
  }
}
