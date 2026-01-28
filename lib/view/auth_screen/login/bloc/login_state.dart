import '../model/user.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse loginResponse;

  LoginSuccess({required this.loginResponse});
  User get user => loginResponse.user;
  String get token => loginResponse.token;
  String get message => loginResponse.message;
  String get navigatorPage => loginResponse.navigatorPage;
  bool get verificationStatus => loginResponse.verificationStatus;
}

class LoginFailure extends LoginState {
  final String error;
  final int? statusCode;

  LoginFailure({required this.error, this.statusCode});
}