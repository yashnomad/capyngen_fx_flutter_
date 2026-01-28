import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../config/flavor_assets.dart';
import '../../theme/app_flavor_color.dart';
import '../../widget/button/premium_app_button.dart';
import '../home_page/home_page_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _textAnimController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _textAnimController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Painter for depth
          Positioned.fill(
            child: CustomPaint(
              painter: ChartBackgroundPainter(
                color: AppFlavorColor.primary.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHelpButton(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(),
                          const SizedBox(height: 32),

                          // REPLACEMENT 1: Trading Stat Cards (Fills the gap)
                          _buildTradingHighlights(),

                          const SizedBox(height: 32),
                          _buildSignInButton(),
                          const SizedBox(height: 16),
                          _buildRegisterButton(),
                          const SizedBox(height: 24),

                          // REPLACEMENT 2: Divider + Risk Warning (Fills bottom)
                          _buildDivider(),
                          const SizedBox(height: 20),
                          _buildRiskWarning(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... [Keep _buildHelpButton, _buildLogo, _buildAnimatedText exactly as before] ...

  // PASTE THESE WIDGETS BELOW to replace the Google Button logic:

  Widget _buildHelpButton() {
    // ... same as previous code
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: context.boxDecorationColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Help", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.helpIconColor)),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: context.helpIconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // ... same as previous code
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: context.boxDecorationColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppFlavorColor.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border: Border.all(
                    color: AppColor.blueColor.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppFlavorColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.candlestick_chart_rounded, size: 32, color: AppFlavorColor.primary),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedText(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to your trading journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String text = FlavorAssets.appName.substring(0, _textAnimation.value);
        return Text(
          text,
          style:  TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppFlavorColor.primary,
          ),
        );
      },
    );
  }

  // --- NEW: Fills the middle space with "Pro" looking stats ---
  Widget _buildTradingHighlights() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHighlightCard("Fast", "Withdrawal", Icons.rocket_launch_rounded),
              _buildHighlightCard("0%", "Commission", Icons.percent_rounded),
              _buildHighlightCard("24/7", "Support", Icons.headset_mic_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightCard(String title, String subtitle, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.boxDecorationColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppFlavorColor.primary.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.profileIconColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Create Account',
            icon: Icons.person_add_rounded,
            showIcon: true,
            onPressed: () {
              context.pushNamed('yourResidence');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Sign In',
            icon: Icons.login_rounded,
            showIcon: true,
            // You can change button color logic here if you want it outlined
            // but sticking to PremiumAppButton for consistency
            onPressed: () {
              context.pushNamed('login');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade200)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.gpp_good_rounded, color: Colors.grey.shade400, size: 16),
              ),
              Expanded(child: Divider(color: Colors.grey.shade200)),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Risk Warning fills the bottom elegantly ---
  Widget _buildRiskWarning() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                "Risk Warning",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Trading derivatives involves high risk to your capital and you should only trade with money you can afford to lose.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Background Painter (Kept this as it adds great visual depth)
class ChartBackgroundPainter extends CustomPainter {
  final Color color;
  ChartBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
        size.width * 0.25, size.height * 0.75,
        size.width * 0.5, size.height * 0.5,
        size.width, size.height * 0.3
    );

    canvas.drawPath(path, paint);

    final circlePaint = Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.15), 80, circlePaint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.85), 40, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math; // Added for background drawing
import '../../config/flavor_assets.dart';
import '../../theme/app_flavor_color.dart';
import '../../widget/button/premium_app_button.dart';
import '../home_page/home_page_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _textAnimController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _textAnimController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textAnimController.dispose();
    super.dispose();
  }

  // --- WIDGET BUILDER ---

  @override
  Widget build(BuildContext context) {
    // We use a Stack to put a decorative background behind your content
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Subtle Background decoration to fill emptiness
          Positioned.fill(
              child: CustomPaint(
                  painter: ChartBackgroundPainter(
                      color: AppFlavorColor.primary.withOpacity(0.05)))),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHelpButton(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(),
                          const SizedBox(height: 40),

                          // NEW: Features row to fill middle space
                          _buildFeaturesRow(),

                          const SizedBox(height: 40),
                          _buildSignInButton(),
                          const SizedBox(height: 16),
                          _buildRegisterButton(), // Swapped order for better UX (Sign in usually primary or split)
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 24),
                          _buildGoogleButton(), // Visual enhancer
                          const SizedBox(height: 20),
                          _createAccount(), // Changed to "Terms" or keep as alternative
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT METHODS ---

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        String text = FlavorAssets.appName.substring(0, _textAnimation.value);
        return Text(
          text,
          style: TextStyle(
            fontSize: 32, // Increased size slightly
            fontWeight: FontWeight.bold,
            color: AppFlavorColor.primary,
          ),
        );
      },
    );
  }

  Widget _buildHelpButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: context.boxDecorationColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8), // Wider button
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Help",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: context.helpIconColor)),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: context.helpIconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: context.boxDecorationColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppFlavorColor.primary.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                  border: Border.all(
                    color: AppColor.blueColor.withOpacity(0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Added a decorative icon above text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppFlavorColor.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.show_chart_rounded,
                          size: 32, color: AppFlavorColor.primary),
                    ),
                    const SizedBox(height: 16),
                    _buildAnimatedText(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to your trading journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Adds visual weight to the middle of the screen
  Widget _buildFeaturesRow() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _featureItem(Icons.security, "Secure"),
            _verticalDivider(),
            _featureItem(Icons.flash_on_rounded, "Fast"),
            _verticalDivider(),
            _featureItem(Icons.public, "Global"),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey.shade400, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(height: 20, width: 1, color: Colors.grey.shade200);
  }

  Widget _buildRegisterButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Create Account',
            icon: Icons.person_add_rounded,
            showIcon: true,
            // You might want to make this outlined style if your button supports it,
            // otherwise keep as is.
            onPressed: () {
              context.pushNamed('yourResidence');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Sign In',
            icon: Icons.login_rounded,
            showIcon: true,
            // Usually Sign In is the primary action for returning users
            onPressed: () {
              context.pushNamed('login');
            },
          ),
        ),
      ),
    );
  }

  // NEW: Google Button to fill bottom space
  Widget _buildGoogleButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            height: 54, // Match your PremiumAppButton height
            decoration: BoxDecoration(
              color: context.boxDecorationColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // Add Google Sign In Logic
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Replace with actual asset if you have one
                    const Icon(Icons.g_mobiledata, size: 30),
                    const SizedBox(width: 8),
                    Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createAccount() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: TextButton(
            onPressed: () {},
            child: RichText(
              text: TextSpan(
                text: "By continuing, you agree to our ",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                children: [
                  TextSpan(
                    text: "Terms & Conditions",
                    style: TextStyle(
                      color: AppFlavorColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- NEW BACKGROUND PAINTER ---
// This draws a subtle financial chart line in the background
class ChartBackgroundPainter extends CustomPainter {
  final Color color;
  ChartBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Start slightly off screen left
    path.moveTo(0, size.height * 0.7);

    // Draw a "chart" looking curve
    path.cubicTo(
        size.width * 0.25,
        size.height * 0.75, // Control point 1
        size.width * 0.5,
        size.height * 0.5, // Control point 2
        size.width,
        size.height * 0.3 // End point
        );

    canvas.drawPath(path, paint);

    // Draw a decorative circle top right
    final circlePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.15), 60, circlePaint);

    // Draw a decorative circle bottom left
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.85), 40, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
*/

/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/flavor_assets.dart';
import '../../theme/app_flavor_color.dart';
import '../../widget/button/premium_app_button.dart';
import '../home_page/home_page_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _textAnimController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _textAnimController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _textAnimController.dispose();

    super.dispose();
  }

  Widget _buildHelpButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: context.boxDecorationColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blackColor.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 24,
                      color: context.helpIconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 7,
                height: 110,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50.withOpacity(0.8),
                      Colors.purple.shade50.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColor.blueColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: _buildAnimatedText(),
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome to your trading journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Create Account',
            icon: Icons.person_add_rounded,
            showIcon: true,
            onPressed: () {
              context.pushNamed('yourResidence');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PremiumAppButton(
            text: 'Sign In',
            icon: Icons.login_rounded,
            showIcon: true,
            onPressed: () {
              context.pushNamed('login');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.transparent,
                        Colors.grey.shade300,
                        AppColor.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.transparent,
                        Colors.grey.shade300,
                        AppColor.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createAccount() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                context.pushNamed('yourResidence');
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: Colors.grey,
                    // color: AppFlavorColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    "Create one",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppFlavorColor.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
*/

/*
  Widget _buildGoogleButton() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColor.whiteColor,
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isGoogleLoading
                    ? null
                    : () => _handleGoogleSignIn(context),
                child: Container(
                  alignment: Alignment.center,
                  child: _isGoogleLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey.shade600),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/image/google.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
*/

/*
  Widget _buildFooterText() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'By continuing, you agree to our Terms of Service and Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              height: 1.4,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
*/

// Widget _buildAnimatedText() {
//   return AnimatedBuilder(
//     animation: _textAnimation,
//     builder: (context, child) {
//       final text = FlavorAssets.appName;
//       final visibleLength = _textAnimation.value;
//
//       return Row(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: List.generate(
//           visibleLength,
//           (index) {
//             final char = text[index];
//             final reverseIndex = visibleLength - 1 - index;
//             final delay = reverseIndex * 0.05;
//
//             return TweenAnimationBuilder<double>(
//               duration: Duration(milliseconds: 300),
//               tween: Tween(begin: 0.0, end: 1.0),
//               curve: Curves.elasticOut,
//               builder: (context, value, child) {
//                 return Transform.scale(
//                   scale: value,
//                   child: Text(
//                     char,
//                      maxLines: 1,
//                     style: TextStyle(
//                       fontSize: 36 * value,
//                       fontWeight: FontWeight.w900,
//                       letterSpacing: 1.2,
//                       color: AppColor.blackColor,
//                       overflow: TextOverflow.ellipsis,
//
//                       shadows: [
//                         Shadow(
//                           color: AppColor.blueColor.withOpacity(0.3 * value),
//                           offset: const Offset(0, 2),
//                           blurRadius: 8,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       );
//     },
//   );
// }

//   Widget _buildAnimatedText() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return AnimatedBuilder(
//           animation: _textAnimation,
//           builder: (context, child) {
//             final fullText = FlavorAssets.appName;
//             final visibleLength =
//                 _textAnimation.value.clamp(0, fullText.length);
//             final visibleText = fullText.substring(0, visibleLength);
//
//             return SizedBox(
//               width: constraints.maxWidth,
//               child: Text(
//                 visibleText,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.w900,
//                   letterSpacing: 1.2,
//                   color: AppColor.blackColor,
//                   shadows: [
//                     Shadow(
//                       color: AppColor.blueColor.withOpacity(0.3),
//                       offset: const Offset(0, 2),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: context.scaffoldBackgroundColor,
//       appBar: AppBar(
//         toolbarHeight: 0,
//         backgroundColor: Colors.transparent,
//         systemOverlayStyle: context.appBarIconBrightness,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHelpButton(),
//             const Spacer(flex: 2),
//             _buildLogo(),
//             const Spacer(flex: 3),
//             // _buildRegisterButton(),
//             // const SizedBox(height: 16),
//             // _buildDivider(),
//             const SizedBox(height: 16),
//
//             _buildSignInButton(),
//             const SizedBox(height: 24),
//
//             _createAccount(),
//             // _buildDivider(),
//             // const SizedBox(height: 24),
//             // _buildGoogleButton(),
//             const SizedBox(height: 24),
//             _buildFooterText(),
//             const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }
