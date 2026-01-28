import 'package:exness_clone/view/auth_screen/register/model/register.dart';

abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final Register registerResponse;
  final String? navigatorPage;

  RegistrationSuccess({
    required this.registerResponse,
    this.navigatorPage,
  });
}

class RegistrationFailure extends RegistrationState {
  final String message;

  RegistrationFailure({required this.message});
}
