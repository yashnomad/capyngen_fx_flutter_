
abstract class UserProfileEvent {}

class FetchUserProfile extends UserProfileEvent {}

class ClearUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final String fullName;
  final String country;
  final String city;

  UpdateUserProfile({
    required this.fullName,
    this.country = '',
    this.city = '',
  });
}