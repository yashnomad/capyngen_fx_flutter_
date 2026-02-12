import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/bottom_nav_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view/account/buy_sell_trade/cubit/trade_cubit.dart';

import '../services/app_socket.dart';
import '../view/auth_screen/login/model/user.dart';
import 'api_controller.dart';
import 'api_endpoint.dart';
import 'api_response.dart';

class ApiService {
  static final ApiController _apiController = ApiController.instance;

  static void initialize() {
    _apiController.initialize();
  }

  static Future<ApiResponse<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    final response = await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.success && response.data?['token'] != null) {
      final loginResponse = LoginResponse.fromJson(response.data!);

      await StorageService.saveToken(loginResponse.token);
      await StorageService.saveUser(loginResponse.user);
      _apiController.setAuthToken(response.data!['token']);
    }

    return response;
  }

  static Future<ApiResponse<Map<String, dynamic>>> register(
    Map<String, dynamic> userData,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.register,
      data: userData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> verifyEmail(
    String email,
    String otp,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.verifyEmail,
      data: {
        'email': email,
        'otp': otp,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> resendEmail(
    String userId,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.resendEmail,
      data: {'user_id': userId},
    );
  }

  // static Future<ApiResponse<Map<String, dynamic>>> submitKyc(
  //   Map<String, dynamic> kycData,
  // ) async {
  //   return await _apiController.post<Map<String, dynamic>>(
  //     ApiEndpoint.submitKyc,
  //     data: kycData,
  //   );
  // }

  static Future<ApiResponse<Map<String, dynamic>>> submitKyc(
    Map<String, dynamic> kycData,
  ) async {
    return await _apiController.postMultipart<Map<String, dynamic>>(
      ApiEndpoint.submitKyc,
      data: kycData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.userProfile,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await _apiController.put<Map<String, dynamic>>(
      ApiEndpoint.userProfile,
      data: profileData,
    );
  }

  // class ApiService
  static Future<ApiResponse<Map<String, dynamic>>> editUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await _apiController.put<Map<String, dynamic>>(
      ApiEndpoint.updateProfile,
      data: profileData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createTradeAccount(
    Map<String, dynamic> accountData,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.createTradeAccount,
      data: accountData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getTradeAccounts() async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.getTradeAccounts,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getTradeAccountDetails(
    String accountId,
  ) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.getTradeAccountDetails(accountId),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> withdraw(
    Map<String, dynamic> accountData,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.withdraw,
      data: accountData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> deposit(
    Map<String, dynamic> accountData,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.deposit,
      data: accountData,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getDepositList({
    required String tradeUserId,
    required int pageSize,
    required int pageNumber,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.getDepositList,
      queryParameters: {
        'trade_user_id': tradeUserId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getWithdrawList({
    required String tradeUserId,
    required int pageSize,
    required int pageNumber,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.getWithdrawList,
      queryParameters: {
        'trade_user_id': tradeUserId,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateBankAccount(
    Map<String, dynamic> accountData,
  ) async {
    return await _apiController.patch(ApiEndpoint.updateBankDetail,
        data: accountData);
  }

  static Future<ApiResponse<Map<String, dynamic>>> internalTransfer(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.internalTransfer, data: data);
  }

  static Future<ApiResponse<Map<String, dynamic>>> depositCrypto(
    Map<String, dynamic> accountData,
  ) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.depositCrypto,
      data: accountData,
    );
  }

  //cryptoPaymentStatus

  // class name ApiService
  static Future<ApiResponse<Map<String, dynamic>>> cryptoPaymentStatus(
      String cryptoId) async {
    return await _apiController.get(ApiEndpoint.cryptoPaymentStatus(cryptoId));
  }

  // ✅ Twelve Data

  static Future<ApiResponse<Map<String, dynamic>>> fetchMarketData() async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.getWithdrawList,
    );
  }

  static Future<void> logout(BuildContext context) async {
    try {
      // context.read<DataFeedProvider>().reset();
      context.read<DataFeedProvider>().reset();
      context.read<TradeCubit>().reset();
      AppSocket().disconnect();

      // 2. Clear auth token
      _apiController.clearAuthToken();
      await StorageService.clearExceptPin();
      BottomNavHelper.goTo(0);

      if (context.mounted) {
        context.goNamed('auth');
      }
    } catch (e, st) {
      debugPrint('⚠️ Logout failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  static void setAuthToken(String token) {
    _apiController.setAuthToken(token);
  }

  // Class ApiService
  static Future<ApiResponse<Map<String, dynamic>>> fetchTicket() async {
    return await _apiController.get(
      ApiEndpoint.ticket,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> createTicket(
    Map<String, dynamic> ticketData,
  ) async {
    try {
      PlatformFile? attachmentFile = ticketData['attachments'];

      if (attachmentFile != null) {
        return await _apiController.postMultipart<Map<String, dynamic>>(
          ApiEndpoint.ticket,
          data: ticketData,
        );
      } else {
        return await _apiController.post<Map<String, dynamic>>(
          ApiEndpoint.ticket,
          data: {
            'subject': ticketData['subject'],
            'description': ticketData['description'],
          },
        );
      }
    } catch (e) {
      return ApiResponse.error(
        e,
        message: 'Failed to create ticket: ${e.toString()}',
      );
    }
  }

  // Class ApiService

  static Future<ApiResponse<Map<String, dynamic>>>
      fetchReferralCommission() async {
    return await _apiController.get(
      ApiEndpoint.referralCommission,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> feedback(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.feedback, data: data);
  }

  // fetch symbols

  // ApiService
  // fetch all symbols
  static Future<ApiResponse<Map<String, dynamic>>> getAllSymbols() async {
    return await _apiController
        .get<Map<String, dynamic>>(ApiEndpoint.symbolDetails);
  }

  // getAdded symbols
  static Future<ApiResponse<Map<String, dynamic>>> getWatchListSymbols(
      String id) async {
    return await _apiController
        .get<Map<String, dynamic>>(ApiEndpoint.watchlist(id));
  }

  // add symbols
  static Future<ApiResponse<Map<String, dynamic>>> addSymbols(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.addWatchlist, data: data);
  }

  // add symbols
  static Future<ApiResponse<Map<String, dynamic>>> removeSymbol(
      String id) async {
    return await _apiController.delete(ApiEndpoint.removeSymbol(id));
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> saveActiveTradeAccount(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.activeTradeAccount,
        data: data);
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> getActiveTradeAccount(
      Map<String, dynamic> data) async {
    return await _apiController.get(ApiEndpoint.activeTradeAccount);
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> companyGroup() async {
    return await _apiController.get(ApiEndpoint.companyGroup);
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> accountList() async {
    return await _apiController.get(ApiEndpoint.accountList);
  }

  // https://api.capyngen.us/user/tradeAccount/68cfde7e75b373db4df5611f/topup

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> demoDeposit(
      Map<String, dynamic> data, String id) async {
    return await _apiController.post(ApiEndpoint.demoDeposit(id), data: data);
  }

  static Future<ApiResponse<Map<String, dynamic>>> forgetPassword(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.forgetPassword, data: data);
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> package() async {
    return await _apiController.get(ApiEndpoint.package);
  }

  static Future<ApiResponse<Map<String, dynamic>>> createInvestment(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.createInvestment, data: data);
  }

  static Future<ApiResponse<Map<String, dynamic>>> getInvestment(
      String tradeUserId) async {
    return await _apiController
        .get(ApiEndpoint.getInvestment(tradeUserId: tradeUserId));
  }

// ApiService
//   static Future<ApiResponse<Map<String, dynamic>>> updateBankAccount(
//       Map<String, dynamic> data) async {
//     return await _apiController.patch(ApiEndpoint.updateBankAccount,
//         data: data);
//   }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> getCryptoAddress() async {
    return await _apiController.get(ApiEndpoint.getCryptoAddress);
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> createCryptoAddress(
      Map<String, dynamic> data) async {
    return await _apiController.post(ApiEndpoint.createCryptoAddress,
        data: data);
  }

  static Future<ApiResponse<Map<String, dynamic>>> createTrade(
      Map<String, dynamic> data) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.buySellTrade,
      data: data,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getOpenTrades(
      String accountId) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.tradeList,
      queryParameters: {
        'accountId': accountId,
        'status': 'open',
        'pageSize': 500,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getTradesByStatus(
      String accountId, String status) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.tradeList,
      queryParameters: {
        'accountId': accountId,
        'status': status,
        'pageSize': 500,
      },
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getTradeHistory({
    required String accountId,
    int page = 1,
    int pageSize = 1000,
    String? fromDate,
  }) async {
    final queryParams = {
      'accountId': accountId,
      'status': 'closed',
      'pageNumber': page,
      'pageSize': pageSize,
    };

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate;
    }

    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.tradeList,
      queryParameters: queryParams,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateTrade(
      String tradeId, Map<String, dynamic> data) async {
    return await _apiController.put<Map<String, dynamic>>(
      ApiEndpoint.updateTrade(tradeId),
      data: data,
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> stopTrade(
      Map<String, dynamic> data) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.closeTrade,
      data: data,
    );
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.dashboard,
    );
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> getHistoricalData({
    required String symbol,
    required int timeframe,
    required int fromMs,
    required int toMs,
    required String tradeUserId,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.candleList(
        symbol: symbol,
        timeframe: timeframe,
        fromMs: fromMs,
        toMs: toMs,
        tradeUserId: tradeUserId,
      ),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> getMasterAccount({
    required String tradeUserId,
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.masterAccount(
        tradeUserId: tradeUserId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  // ApiService
  static Future<ApiResponse<Map<String, dynamic>>> getFollowerList({
    required String masterUserId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.followerList(
        masterUserId: masterUserId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> referralLink() async {
    return await _apiController
        .get<Map<String, dynamic>>(ApiEndpoint.referralLink);
  }

  static Future<ApiResponse<Map<String, dynamic>>> getLeaderboard({
    required String type,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await _apiController.get<Map<String, dynamic>>(
      ApiEndpoint.leaderboard(
        type: type,
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> followTraderAndRemove({
    required Map<String, dynamic> data,
  }) async {
    return await _apiController.post<Map<String, dynamic>>(
      ApiEndpoint.followTraderAndRemove,
      data: data,
    );
  }
}
