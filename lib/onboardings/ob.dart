import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:exness_clone/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  void _completeOnboarding() async {
    await StorageService.setFirstLaunchCompleted();
    if (mounted) {
      context.goNamed('auth');
    }
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = AppFlavorColor.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (v) => setState(() => _index = v),
                children: [
                  _OnboardPage(
                    image: 'assets/onboard1.png',
                    title: 'Welcome To',
                    highlight: FlavorConfig.title,
                    subtitle:
                        'Trade smarter with a powerful platform built for speed, clarity, and confidence. '
                        'Access real-time prices, advanced charts, and seamless execution—all in one place.',
                    alignment: CrossAxisAlignment.start,
                  ),
                  _OnboardPage(
                    image: 'assets/onboard2.png',
                    title: 'Transaction',
                    highlight: 'Security',
                    subtitle:
                        'Your assets are safeguarded with bank-grade encryption, secure servers, and '
                        'multi-layer protection—so you can trade with complete peace of mind.',
                    alignment: CrossAxisAlignment.start,
                  ),
                  _OnboardPage(
                    image: 'assets/onboard3.png',
                    title: 'Fast And Reliable',
                    highlight: 'Market Updates.',
                    subtitle:
                        'Never miss a move. Get instant price updates, real-time alerts, and ultra-fast '
                        'order execution to stay ahead of the market. Trade with speed and confidence.',
                    alignment: CrossAxisAlignment.start,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: size.height * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _index == i ? 24 : 6, // Dash for active
                        decoration: BoxDecoration(
                          color:
                              _index == i ? primaryColor : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.2),
                      ),
                      padding: const EdgeInsets.all(8), // Outer ring padding
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                        child: const Icon(Icons.arrow_forward,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String highlight;
  final String subtitle;
  final CrossAxisAlignment alignment;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.highlight,
    required this.subtitle,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          SizedBox(height: size.height * 0.02),
          Align(
            alignment: Alignment.center, // Image usually centered
            child: AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child: Image.asset(
                image,
                height: size.height * 0.35,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const Spacer(),
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontFamily: 'Poppins', // Ensure font is used if available
                height: 1.2,
              ),
              children: [
                TextSpan(text: '$title\n'),
                TextSpan(
                  text: highlight,
                  style: TextStyle(color: AppFlavorColor.primary),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            subtitle,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
