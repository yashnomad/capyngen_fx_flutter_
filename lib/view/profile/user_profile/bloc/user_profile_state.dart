import '../model/user_profile.dart';

/*abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;
  UserProfileLoaded(this.profile);
}

class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}*/


abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile profile;
  UserProfileLoaded(this.profile);
}

class UserProfileUpdating extends UserProfileState {}

class UserProfileUpdated extends UserProfileState {
  final String message;
  UserProfileUpdated(this.message);
}

class UserProfileError extends UserProfileState {
  final String message;
  UserProfileError(this.message);
}