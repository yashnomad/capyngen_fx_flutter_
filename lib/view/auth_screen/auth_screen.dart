import 'package:exness_clone/config/flavor_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exness_clone/theme/app_flavor_color.dart'; // Add this import

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  // Changed to TickerProviderStateMixin for multiple controllers
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late AnimationController _textAnimController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();

    // Existing fade animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Text animation controller
    _textAnimController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textAnimation = IntTween(
      begin: 0,
      end: FlavorAssets.appName.length,
    ).animate(
      CurvedAnimation(
        parent: _textAnimController,
        curve: Curves.easeInOut,
      ),
    );

    // Start text animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _textAnimController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String text = FlavorAssets.appName.substring(0, _textAnimation.value);
        return Text(
          text,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryYellow = AppFlavorColor.primary;
    final Color textColor = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                // const SizedBox(height: 5),

                // Replace static text with animated text
                _buildAnimatedText(),

                const Spacer(flex: 1),

                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/image/auth_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image_not_supported_rounded,
                          size: 100, color: Colors.grey.shade300);
                    },
                  ),
                ),

                const Spacer(flex: 1),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome To Your Trading Journey.",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Trade smarter with real-time market insights, powerful tools, and a seamless experience designed for every trader.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            context.pushNamed('yourResidence');
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppFlavorColor.primary, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppFlavorColor.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            context.pushNamed('login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppFlavorColor.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Log in",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.gpp_good_rounded,
                          color: Colors.green, size: 20),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Risk Warning",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Trading Derivatives Involves High Risk To Your Capital And You Should\nOnly Trade With Money You Can Afford To Lose.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey.shade400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
