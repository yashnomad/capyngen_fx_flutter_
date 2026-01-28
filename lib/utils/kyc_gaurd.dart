import 'dart:async';

import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../network/api_service.dart';
import '../view/profile/user_profile/model/user_profile.dart';

enum KycStatus {
  notStarted,
  pending,
  approved,
  rejected,
  suspended,
}

KycStatus parseKycStatus(String? status) {
  switch (status) {
    case 'approved':
    case 'verified':
      return KycStatus.approved;
    case 'pending':
      return KycStatus.pending;
    case 'rejected':
      return KycStatus.rejected;
    case 'suspended':
      return KycStatus.suspended;
    default:
      return KycStatus.notStarted;
  }
}

class KycService {
  const KycService();

  Future<bool> checkAndHandleKyc(BuildContext context) async {
    try {
      final response =
          await ApiService.getUserProfile().timeout(const Duration(seconds: 8));

      if (response.data?['success'] != true) {
        SnackBarService.showError('Unable to verify KYC');
        return false;
      }

      final userProfile = UserProfile.fromJson(response.data!);
      final profile = userProfile.profile;

      if (profile == null) {
        SnackBarService.showError('Profile not found');
        return false;
      }

      final status = parseKycStatus(profile.kycStatus);

      if (!context.mounted) return false;

      CommonUtils.debugPrintWithTrace(profile.toString());
      CommonUtils.debugPrintWithTrace(status.toString());
      switch (status) {
        case KycStatus.approved:
          return true;

        case KycStatus.pending:
          SnackBarService.showInfo('Please complete KYC to continue.');
          context.push('/uploadDocument');
          return false;

        case KycStatus.rejected:
          SnackBarService.showError('Your KYC was rejected. Please resubmit.');
          context.push('/kycVerification');
          return false;

        case KycStatus.notStarted:
          SnackBarService.showError('Please complete KYC to continue.');
          context.push('/kycVerification');
          return false;

        case KycStatus.suspended:
          SnackBarService.showError(
            'Your account is suspended. Contact support.',
          );
          return false;
      }
    } on TimeoutException {
      SnackBarService.showError('KYC verification timed out');
      return false;
    } catch (e) {
      SnackBarService.showError('KYC verification failed');
      return false;
    }
  }
}

/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view/profile/user_profile/bloc/user_profile_bloc.dart';
import '../view/profile/user_profile/bloc/user_profile_event.dart';
import '../view/profile/user_profile/bloc/user_profile_state.dart';
import '../view/profile/user_profile/model/user_profile.dart';
import 'snack_bar.dart';

enum KycStatus {
  notStarted,
  pending,
  approved,
  rejected,
  suspended,
}

KycStatus parseKycStatus(String? status) {
  switch (status) {
    case 'approved':
    case 'verified':
      return KycStatus.approved;
    case 'pending':
      return KycStatus.pending;
    case 'rejected':
      return KycStatus.rejected;
    case 'suspended':
      return KycStatus.suspended;
    default:
      return KycStatus.notStarted;
  }
}

/// 🔐 ALWAYS checks latest profile from server
Future<bool> kycGuard({
  required BuildContext context,
}) async {
  final bloc = context.read<UserProfileBloc>();

  // 🔄 Force refresh profile
  bloc.add(FetchUserProfile());

  try {
    final state = await bloc.stream
        .firstWhere((state) => state is UserProfileLoaded)
        .timeout(const Duration(seconds: 8));

    final profile = (state as UserProfileLoaded).profile.profile;

    final status = parseKycStatus(profile?.kycStatus);

    switch (status) {
      case KycStatus.approved:
        return true;

      case KycStatus.pending:
        SnackBarService.showInfo('Your KYC is under review.');
        context.push('/kycStatus');
        return false;

      case KycStatus.rejected:
        SnackBarService.showError('Your KYC was rejected. Please resubmit.');
        context.push('/kycVerification');
        return false;

      case KycStatus.notStarted:
        SnackBarService.showError('Please complete KYC to continue.');
        context.push('/kycVerification');
        return false;

      case KycStatus.suspended:
        SnackBarService.showError(
            'Your account is suspended. Contact support.');
        return false;
    }
  } on TimeoutException {
    SnackBarService.showError('Unable to verify KYC. Please try again.');
    return false;
  }
}
*/
