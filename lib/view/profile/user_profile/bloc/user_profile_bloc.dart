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
    on<KycSubmitted>(_onKycSubmitted);
  }

  /// Optimistically sets kycStatus to 'under_review' locally.
  /// Does NOT re-fetch from server (server may still return 'rejected'
  /// for a few seconds after submission). Fresh data will load on next
  /// app start via splash screen's FetchUserProfile.
  void _onKycSubmitted(KycSubmitted event, Emitter<UserProfileState> emit) {
    if (state is UserProfileLoaded) {
      final current = (state as UserProfileLoaded).profile;
      final p = current.profile;
      if (p != null) {
        final updated = Profile(
          documentType: p.documentType,
          bank: p.bank,
          upiDetails: p.upiDetails,
          id: p.id,
          fullName: p.fullName,
          accountId: p.accountId,
          email: p.email,
          referedBy: p.referedBy,
          referedCode: p.referedCode,
          currency: p.currency,
          isVerified: p.isVerified,
          accountStatus: p.accountStatus,
          brokerId: p.brokerId,
          kycApprovedBy: p.kycApprovedBy,
          kycStatus: 'under_review',
          country: p.country,
          city: p.city,
          loginAt: p.loginAt,
          activeTradeAccount: p.activeTradeAccount,
          createdAt: p.createdAt,
          updatedAt: p.updatedAt,
          v: p.v,
          verificationStatus: p.verificationStatus,
          navigatorPage: p.navigatorPage,
        );
        emit(UserProfileLoaded(
          UserProfile(success: true, profile: updated),
        ));
      }
    }
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
