import 'package:exness_clone/view/app_auth/provider/app_auth_provider.dart';
import 'package:exness_clone/view/home_page/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_auth_screen.dart';
import 'app_auth_splash.dart';

class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isInitialized) {
          return const AppSplashScreen();
        }
        if (authProvider.isAuthenticated) {
          return HomePageScreen();
        }
        return const AppAuthScreen();
      },
    );
  }
}
