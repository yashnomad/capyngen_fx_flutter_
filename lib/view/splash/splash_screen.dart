import 'dart:async';

import 'package:exness_clone/constant/app_strings.dart';
import 'package:exness_clone/services/symbol_service.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/profile/user_profile/model/user_profile.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/flavor_config.dart';
import '../../network/api_service.dart';
import '../../services/storage_service.dart';
import '../../services/data_feed_ws.dart';
import '../auth_screen/auth_screen.dart';
import '../home_page/home_page_screen.dart';
import '../profile/user_profile/bloc/user_profile_bloc.dart';
import '../profile/user_profile/bloc/user_profile_event.dart';
import '../profile/user_profile/bloc/user_profile_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
    // _initTradingView();
    Future.delayed(Duration(seconds: 2));
  }

  Future<void> _checkToken() async {
    debugPrint('[Splash] Starting _checkToken');

    await Future.delayed(const Duration(milliseconds: 500));

    if (StorageService.isFirstLaunch()) {
      debugPrint('[Splash] First launch detected. Navigating to onboarding.');
      if (!mounted) return;
      context.goNamed('onboard');
      return;
    }

    final token = StorageService.getToken();
    debugPrint('[Splash] Retrieved token: $token');

    if (token != null && token.isNotEmpty) {
      try {
        final jwt = JWT.decode(token);
        final exp = jwt.payload['exp'];
        debugPrint('[Splash] Token decoded, exp: $exp');

        if (exp != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final isExpired = DateTime.now().isAfter(expiryDate);
          debugPrint(
              '[Splash] Token expiry date: $expiryDate, isExpired: $isExpired');

          if (!isExpired) {
            debugPrint('[Splash] Token is valid. Setting API token...');
            ApiService.setAuthToken(token);

            if (!mounted) return;
            final bloc = context.read<UserProfileBloc>();
            debugPrint('[Splash] Dispatching FetchUserProfile event...');
            bloc.add(FetchUserProfile());

            try {
              await bloc.stream
                  .firstWhere((state) => state is UserProfileLoaded)
                  .timeout(const Duration(seconds: 10));

              if (!mounted) return;

              final profileState = bloc.state;
              if (profileState is UserProfileLoaded) {
                final navigatorPage =
                    profileState.profile.profile?.navigatorPage;
                debugPrint(
                    '[Splash] UserProfileLoaded received, navigatorPage: $navigatorPage');

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  switch (navigatorPage) {
                    case '/dashboard':
                      debugPrint('[Splash] Navigating to: home');
                      // context.goNamed('appAuthGate'); // AppAuth Screen
                      context.goNamed('home');
                      break;
                    case '/verify-email':
                      debugPrint('[Splash] Navigating to: verifyEmail');
                      context.goNamed('verifyEmail');
                      break;
                    case '/kyc-status':
                      debugPrint('[Splash] Navigating to: kycStatus');
                      context.goNamed('kycStatus');
                      break;
                    case '/kyc-verification':
                      debugPrint('[Splash] Navigating to: kycVerification');
                      context.goNamed('kycVerification');
                      break;
                    default:
                      debugPrint(
                          '[Splash] navigatorPage unknown or null. Navigating to: auth');
                      context.goNamed('auth');
                  }
                });
                return;
              }
            } on TimeoutException catch (_) {
              debugPrint('[Splash] ❌ Timeout while loading user profile.');
              if (!mounted) return;
              context.goNamed('error');
              return;
            }
          }
        }
      } catch (e) {
        debugPrint('[Splash] Token error: $e');
      }
    }

    debugPrint(
        '[Splash] Token missing/invalid or expired. Clearing storage...');
    await StorageService.clearAll();
    if (!mounted) return;
    debugPrint('[Splash] Navigating to: auth');
    context.goNamed('auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(FlavorConfig.appConfig['primaryColor'] ?? 0xFF1E40AF),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  FlavorConfig.appConfig['logoPath'] ??
                      'assets/images/capmarket/capmarket_logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  FlavorConfig.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Loader(),
          ),
        ],
      ),
    );
  }
}
