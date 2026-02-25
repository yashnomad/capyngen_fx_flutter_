abstract class RegistrationEvent {}

class RegisterUser extends RegistrationEvent {
  final String fullName;
  final String email;
  final String password;
  final String phone;
  final String? referedBy;

  RegisterUser(
      {required this.fullName,
      required this.email,
      required this.password,
      required this.phone,
      this.referedBy});
}
