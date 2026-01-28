abstract class RegistrationEvent {}

class RegisterUser extends RegistrationEvent {
  final String fullName;
  final String email;
  final String password;
  final String? referedBy;

  RegisterUser({
    required this.fullName,
    required this.email,
    required this.password,
    this.referedBy
  });
}