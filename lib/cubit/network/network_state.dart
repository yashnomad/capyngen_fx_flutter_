import 'package:equatable/equatable.dart';

enum ConnectionType { wifi, mobile, ethernet, none }

abstract class NetworkState extends Equatable {
  const NetworkState();

  @override
  List<Object> get props => [];
}

class NetworkInitial extends NetworkState {}

class NetworkConnected extends NetworkState {
  final ConnectionType connectionType;
  const NetworkConnected(this.connectionType);
}

class NetworkDisconnected extends NetworkState {}