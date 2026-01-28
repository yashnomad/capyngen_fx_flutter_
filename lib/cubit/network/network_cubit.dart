import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  NetworkCubit() : super(NetworkInitial()) {
    _monitorInternetConnection();
  }

  void _monitorInternetConnection() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      emit(NetworkDisconnected());
    } else if (results.contains(ConnectivityResult.mobile)) {
      emit(const NetworkConnected(ConnectionType.mobile));
    } else if (results.contains(ConnectivityResult.wifi)) {
      emit(const NetworkConnected(ConnectionType.wifi));
    } else if (results.contains(ConnectivityResult.ethernet)) {
      emit(const NetworkConnected(ConnectionType.ethernet));
    } else {
      emit(const NetworkConnected(ConnectionType.mobile));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
