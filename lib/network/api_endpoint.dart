import '../config/flavor_config.dart';

class ApiEndpoint {
  static const bool isProduction = true;

  static const String _devBaseUrl = 'http://localhost:3000/user';
  // static const String _prodBaseUrl = 'https://api.capyngen.co.uk/user';
  static const String _prodBaseUrl = 'https://api.capyngen.us/user';
  // static const String _prodBaseUrl = 'https://capmarket.onrender.com/user';
  // https://api.capyngen.us/

  static String get baseUrl {
    // const bool isDevelopment = false;
    // if (isDevelopment) {
    //   return _devBaseUrl;
    // }

    return FlavorConfig.baseUrl;
  }

  // static String get baseUrl => isProduction ? _prodBaseUrl : _devBaseUrl;

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendEmail = '/auth/resend-email';

  static const String submitKyc = '/kyc/submit';

  static const String userProfile = '/profile';
  static const String updateProfile = '/profile/update';

  static const String createTradeAccount = '/createTradeAccount';
  static const String getTradeAccounts = '/tradeAccounts';
  static String getTradeAccountDetails(String accountId) =>
      '/tradeAccounts/$accountId';

  static const String withdraw = '/tradeAccount/create/withdraw';
  static const String deposit = '/tradeAccount/create/deposit';

  static String getDepositList = "/tradeAccount/depositList";
  static String getWithdrawList = "/tradeAccount/WithdrawList";
  static String updateBankDetail = "/update-bank-details";
  static const String internalTransfer =
      '/tradeAccount/create/internal-transfer';

  static const String depositCrypto = '/create-payment';
  static String cryptoPaymentStatus(String cryptoId) =>
      '/payment-status/$cryptoId';

  static const String ticket = '/helpdesk/tickets';
  static const String feedback = '/feedback';
  static const String symbolDetails = '/symbol/details';
  static String watchlist(String id) => "/watchlist?trade_user_id=$id";
  static String removeSymbol(String id) => "/remove-watchlist/$id";

  // remove-watchlist

  static const String addWatchlist = '/add-watchlist';

  // static const String buySellTrade = 'trade/create';
  static const String buySellTrade = '/tradeAccount/create/trade';
  static String updateTrade(String tradeId) => '/trade-update/$tradeId';
  static const String closeTrade = '/trade-close';
  static const String referralCommission = '/referelal-commision';
  static const String activeTradeAccount = '/active-trade-account';

  static const String companyGroup = '/company-group';
  static const String accountList = '/merchant/account-list';
  static String demoDeposit(String id) => '/tradeAccount/$id/topup';
  static const String forgetPassword = '/forgot-password';
  static const String package = '/package';
  static const String createInvestment = '/CreateInvestment';
  static String getInvestment({
    required String tradeUserId,
    int pageNumber = 1,
    int pageSize = 10,
  }) =>
      '/getInvestment?trade_user_id=$tradeUserId&pageNumber=$pageNumber&pageSize=$pageSize';

  static const String updateBankAccount = '/update-bank-details';

  static const String getCryptoAddress = '/get-crypto-address';
  static const String createCryptoAddress = '/create-crypto-address';
  static const String tradeList = '/trade/list';
  static const String dashboard = '/dashboard';

  static String candleList({
    required String symbol,
    required int timeframe,
    required int fromMs,
    required int toMs,
    required String tradeUserId,
  }) =>
      '/candle-list'
      '?symbol=$symbol'
      '&timeframe=$timeframe'
      '&fromMs=$fromMs'
      '&toMs=$toMs'
      '&trade_user_id=$tradeUserId';

  static String masterAccount({
    required String tradeUserId,
    int pageNumber = 1,
    int pageSize = 100,
  }) {
    return '/master-account'
        '?trade_user_id=$tradeUserId'
        '&pageNumber=$pageNumber'
        '&pageSize=$pageSize';
  }

  static String followerList({
    required String masterUserId,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return '/follower-list'
        '?master_user_id=$masterUserId'
        '&pageNumber=$pageNumber'
        '&pageSize=$pageSize';
  }

  static String referralLink = '/referelal-link';

  static String leaderboard({
    required String type,
    int pageNumber = 1,
    int pageSize = 10,
  }) {
    return '/leaderboard/$type'
        '?pageNumber=$pageNumber'
        '&pageSize=$pageSize';
  }

  static String followTraderAndRemove = '/followTraderAndRemove';
}
