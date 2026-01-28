import '../model/referral_model.dart';

abstract class IbReportState {}

class IbReportInitial extends IbReportState {}

class IbReportLoading extends IbReportState {}

class IbReportLoaded extends IbReportState {
  final List<ReferralModel> referrals;
  final ReferralSummary summary;
  final List<ReferralModel> filteredReferrals;
  final String searchQuery;
  final String selectedLevel;

  IbReportLoaded({
    required this.referrals,
    required this.summary,
    required this.filteredReferrals,
    this.searchQuery = '',
    this.selectedLevel = 'All Levels',
  });

  IbReportLoaded copyWith({
    List<ReferralModel>? referrals,
    ReferralSummary? summary,
    List<ReferralModel>? filteredReferrals,
    String? searchQuery,
    String? selectedLevel,
  }) {
    return IbReportLoaded(
      referrals: referrals ?? this.referrals,
      summary: summary ?? this.summary,
      filteredReferrals: filteredReferrals ?? this.filteredReferrals,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLevel: selectedLevel ?? this.selectedLevel,
    );
  }
}

class IbReportError extends IbReportState {
  final String message;

  IbReportError(this.message);
}
