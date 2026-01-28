import 'package:exness_clone/core/go_router_observer.dart';
import 'package:exness_clone/main_common.dart';
import 'package:exness_clone/view/account/transaction/internal_transfer/internal_transfer.dart';
import 'package:exness_clone/view/account/withdraw_deposit/withdraw_funds_screen.dart';
import 'package:exness_clone/view/app_auth/app_auth_screen.dart';
import 'package:exness_clone/view/app_auth/auth_gate.dart';
import 'package:exness_clone/view/auth_screen/auth_screen.dart';
import 'package:exness_clone/view/auth_screen/login/signin.dart';
import 'package:exness_clone/view/auth_screen/register/registration_screen.dart';
import 'package:exness_clone/view/auth_screen/register/verify_email-screen.dart';
import 'package:exness_clone/view/auth_screen/verification/document_verification_screen.dart';
import 'package:exness_clone/view/auth_screen/verification/kyc_status_screen.dart';
import 'package:exness_clone/view/auth_screen/verification/upload_document_screen.dart';
import 'package:exness_clone/view/auth_screen/verification/verification_submitted_screen.dart';
import 'package:exness_clone/view/home_page/home_page_screen.dart';
import 'package:exness_clone/view/profile/banking/bank_update_screen.dart';
import 'package:exness_clone/view/splash/splash_screen.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view/account/btc_chart/btc_chart_screen.dart';
import '../view/account/transaction/bloc/transaction_history_bloc.dart';
import '../view/account/transaction/transaction_history.dart';
import '../view/account/withdraw_deposit/crypto_deposit_webview.dart';
import '../view/account/withdraw_deposit/deposit_fund_screen.dart';
import '../view/auth_screen/register/your_residence.dart';
import '../view/profile/add_account/add_account.dart';
import '../view/profile/crypto_wallet/crypto_wallet.dart';
import '../view/splash/error_screen.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [MyRouteObserver()],
  routes: [
    GoRoute(
      path: '/appAuth',
      name: 'app_auth',
      builder: (context, state) => AppAuthGate(),
    ),
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => SplashScreen(),
    ),

    GoRoute(
      path: '/error',
      name: 'error',
      builder: (context, state) => const ErrorScreen(),
    ),

    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/appAuthGate',
      name: 'appAuthGate',
      builder: (context, state) => const AppAuthGate(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => HomePageScreen(),
    ),
    GoRoute(
      path: '/yourResidence',
      name: 'yourResidence',
      builder: (context, state) => YourResidence(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => SignInPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => RegistrationScreen(),
    ),
    GoRoute(
        path: '/verifyEmail',
        name: 'verifyEmail',
        builder: (context, state) => VerifyEmailScreen()),
    GoRoute(
        path: '/kycVerification',
        name: 'kycVerification',
        builder: (context, state) => DocumentVerification()),
    GoRoute(
        path: '/uploadDocument',
        name: 'uploadDocument',
        builder: (context, state) {
          final idTitle = state.name ?? '';
          return UploadDocument(idTitle: idTitle);
        }),
    GoRoute(
        path: '/verificationSubmitted',
        name: 'verificationSubmitted',
        builder: (context, state) => VerificationSubmitted()),
    GoRoute(
        path: '/kycStatus',
        name: 'kycStatus',
        builder: (context, state) => KYCStatusScreen()),
    GoRoute(
        path: '/transactionScreen',
        name: 'transactionScreen',
        builder: (context, state) {
          final String tradeUserId = state.extra as String;
          return BlocProvider(
            create: (context) =>
                TransactionHistoryBloc(tradeUserId: tradeUserId),
            child: TransactionHistory(
              tradeUserId: tradeUserId,
            ),
          );
        }),
    //internalTransfer
    GoRoute(
      path: '/internalTransfer',
      name: 'internalTransfer',
      builder: (context, state) => InternalTransfer(),
    ),

    GoRoute(
      path: '/cryptoWallet',
      name: 'cryptoWallet',
      builder: (context, state) => CryptoWallet(),
    ),

    GoRoute(
      path: '/depositFundScreen',
      name: 'depositFundScreen',
      builder: (context, state) => DepositFundsScreen(),
    ),
    // GoRoute(
    //   path: '/depositCrypto',
    //   name: 'depositCrypto',
    //   builder: (context, state) => DepositCryptoScreen(),
    // ),
    GoRoute(
      path: '/cryptoDepositWebview',
      name: 'cryptoDepositWebview',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final url = data['url'] as String;
        final cryptoId = data['cryptoId'] as String;
        debugPrint("➡️ Navigating to /cryptoDepositWebview with $url");


        return CryptoDepositWebView(
          url: url,
          cryptoId: cryptoId,
        );
      },
    ),

    GoRoute(
      path: '/btcChart',
      name: 'btcChart',
      builder: (context, state) => BTCChartScreen(),
    ),
    GoRoute(
      path: '/withdrawFundsScreen',
      name: 'withdrawFundsScreen',
      builder: (context, state) => WithdrawFundsScreen(),
    ),

    GoRoute(
      path: '/addBankAccount',
      name: 'addBankAccount',
      builder: (context, state) => AddBankAccount(),
    ),
    GoRoute(
      path: '/updateBank',
      name: 'updateBank',
      builder: (context, state) => UpdateBankScreen(),
    ),

    /*  GoRoute(
      path: '/enterNameScreen',
      name: 'enterNameScreen',
      builder: (context, state) => EnterNameScreen(),
    ),
    GoRoute(
      path: '/enterEmailScreen',
      name: 'enterEmailScreen',
      builder: (context, state) {
        final name = state.extra as String? ?? '';

        return EnterEmailScreen(
          name: name,
        );
      },
    ),
    GoRoute(
      path: '/passwordScreen',
      name: 'passwordScreen',
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? {};
        final name = data['name'] ?? '';
        final email = data['email'] ?? '';
        return ChoosePasswordScreen(
          name: name,
          email: email,
        );
      },
    ),*/
  ],
);

/// Uses of go router
// context.go('/profile');         // Replaces current page
// or
// context.push('/profile');       // Pushes on top of current page
// context.goNamed('profile'); // If using named routes
