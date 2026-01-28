  import 'package:flutter_bloc/flutter_bloc.dart';
  import '../../../network/api_service.dart';
  import '../model/referral_model.dart';
  import 'ibreport_state.dart';

  class IbReportCubit extends Cubit<IbReportState> {
    IbReportCubit() : super(IbReportInitial());

    Future<void> fetchReferralCommission() async {
      emit(IbReportLoading());

      try {
        final response = await ApiService.fetchReferralCommission();

        if (response.success && response.data != null) {
          final referralResponse = ReferralResponse.fromJson(response.data!);

          emit(IbReportLoaded(
            referrals: referralResponse.data,
            summary: referralResponse.summary,
            filteredReferrals: referralResponse.data,
          ));
        } else {
          emit(IbReportError(response.message ?? 'Failed to fetch data'));
        }
      } catch (e) {
        emit(IbReportError('An error occurred: $e'));
      }
    }

    void searchReferrals(String query) {
      final currentState = state;
      if (currentState is IbReportLoaded) {
        final filteredList = currentState.referrals.where((item) {
          final searchQuery = query.toLowerCase();
          return item.name.toLowerCase().contains(searchQuery) ||
              item.userAccountId.toLowerCase().contains(searchQuery) ||
              item.country.toLowerCase().contains(searchQuery) ||
              item.accountType.toLowerCase().contains(searchQuery) ||
              item.email.toLowerCase().contains(searchQuery);
        }).toList();

        // Apply level filter as well
        final levelFilteredList = currentState.selectedLevel == 'All Levels'
            ? filteredList
            : filteredList
                .where(
                    (item) => 'Level ${item.level}' == currentState.selectedLevel)
                .toList();

        emit(currentState.copyWith(
          searchQuery: query,
          filteredReferrals: levelFilteredList,
        ));
      }
    }

    void filterByLevel(String level) {
      final currentState = state;
      if (currentState is IbReportLoaded) {
        List<ReferralModel> filteredList = currentState.referrals;

        // Apply search filter
        if (currentState.searchQuery.isNotEmpty) {
          final searchQuery = currentState.searchQuery.toLowerCase();
          filteredList = filteredList.where((item) {
            return item.name.toLowerCase().contains(searchQuery) ||
                item.userAccountId.toLowerCase().contains(searchQuery) ||
                item.country.toLowerCase().contains(searchQuery) ||
                item.accountType.toLowerCase().contains(searchQuery) ||
                item.email.toLowerCase().contains(searchQuery);
          }).toList();
        }

        // Apply level filter
        if (level != 'All Levels') {
          final levelNumber = int.tryParse(level.replaceAll('Level ', '')) ?? 0;
          filteredList =
              filteredList.where((item) => item.level == levelNumber).toList();
        }

        emit(currentState.copyWith(
          selectedLevel: level,
          filteredReferrals: filteredList,
        ));
      }
    }
  }
