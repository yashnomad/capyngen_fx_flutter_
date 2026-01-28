import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../network/api_service.dart';
import '../model/user_profile.dart';
import 'user_profile_event.dart';
import 'user_profile_state.dart';


class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc() : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ClearUserProfile>((event, emit) => emit(UserProfileInitial()));
  }

  Future<void> _onFetchUserProfile(
      FetchUserProfile event, Emitter<UserProfileState> emit) async {
    emit(UserProfileLoading());
    try {
      final response = await ApiService.getUserProfile();
      if (response.data?['success'] == true) {
        final profile = UserProfile.fromJson(response.data!);
        emit(UserProfileLoaded(profile));
      } else {
        emit(UserProfileError(
            response.data?['message'] ?? 'Something went wrong'));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
      UpdateUserProfile event, Emitter<UserProfileState> emit) async {
    emit(UserProfileUpdating());
    try {
      final profileData = {
        'fullName': event.fullName,
        'country': event.country,
        'city': event.city,
      };

      final response = await ApiService.editUserProfile(profileData);

      if (response.data?['success'] == true) {
        emit(UserProfileUpdated(
            response.data?['message'] ?? 'Profile updated successfully'));

        // Fetch latest profile data
        add(FetchUserProfile());
      } else {
        emit(UserProfileError(
            response.data?['message'] ?? 'Failed to update profile'));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
