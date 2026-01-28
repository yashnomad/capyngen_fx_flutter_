import 'dart:async';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import '../../../widget/button/premium_app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? userId;
  const VerifyEmailScreen({super.key, this.userId});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  bool _showResendButton = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isResending = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _timerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _timerAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startResendTimer();

    // Start entrance animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _timerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _timerController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  void _startResendTimer() {
    setState(() {
      _showResendButton = false;
      _secondsRemaining = 60;
    });

    _timerController.reset();
    _timerController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _showResendButton = true);
        timer.cancel();
        // Add a subtle success animation when timer completes
        _timerController.reverse().then((_) {
          _timerController.forward();
        });
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() {
      _isResending = true;
    });

    try {
      if (widget.userId == null) {
        return;
      } else {
        final response = await ApiService.resendEmail(widget.userId ?? '');
        if (response.data?['success'] == true) {
          SnackBarService.showSuccess(response.data?['message']);
          _startResendTimer();
        } else {
          SnackBarService.showSuccess(
              response.data?['message'] ?? "Failed to resend email.");
        }
      }
    } catch (e) {
      SnackBarService.showError('Something went wrong. Please try again.');
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  Widget _buildEmailIcon() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade100.withOpacity(0.8),
                      Colors.purple.shade100.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mark_email_unread_rounded,
                  size: 60,
                  color: Colors.blue.shade600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              'Check Your Email! 📧',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: context.profileIconColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Verification Link Sent',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            'We\'ve sent a verification link to your email address. Please check your inbox (and spam folder) and click the link to continue with your account setup.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
              height: 1.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.amber.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: Check your spam folder if you don\'t see the email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber.shade800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _showResendButton
                  ? [Colors.green.shade50, Colors.green.shade100]
                  : [Colors.grey.shade50, Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _showResendButton
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              if (!_showResendButton) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Didn\'t receive the email?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _timerAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Resend available in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ready to resend!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PremiumAppButton(
                  text: 'Resend Email',
                  isLoading: _isResending,
                  height: 44,
                  icon: Icons.email_outlined,
                  showIcon: true,
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  enableGradient: false,
                  borderRadius: 12,
                  onPressed: _resendEmail,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      appBar: AppBar(
        title: Text(
          'Email Verification',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appBarGradientColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.profileIconColor,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Email Icon
            _buildEmailIcon(),
            const SizedBox(height: 32),

            // Title Section
            _buildTitle(),
            const SizedBox(height: 24),

            // Description
            _buildDescription(),
            const SizedBox(height: 24),

            // Instructions
            _buildInstructions(),
            const SizedBox(height: 32),

            // Continue Button
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PremiumAppButton(
                  text: 'Continue to App',
                  icon: Icons.arrow_forward_rounded,
                  showIcon: true,
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Resend Section
            _buildResendSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/*
import 'dart:async';

import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/utils/url_launcher.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../widget/color.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? userId;
  const VerifyEmailScreen({super.key, this.userId});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _showResendButton = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _showResendButton = false;
    _secondsRemaining = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _showResendButton = true);
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    setState(() {
      _showResendButton = false;
      _startResendTimer();
    });

    try {
      if (widget.userId == null) {
        return;
      } else {
        final response = await ApiService.resendEmail(widget.userId ?? '');
        if (response.data?['success'] == true) {
          SnackBarService.showSuccess(response.data?['message']);
        } else {
          SnackBarService.showSuccess(
              response.data?['message'] ?? "Failed to resend email.");
        }
      }
    } catch (e) {
      SnackBarService.showError('Something went wrong. Please try again.');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email_outlined, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 24),
            const Text(
              'Please verify your email',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We’ve sent a verification link to your email address. '
              'Please check your inbox and click the link to continue.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColor.yellowColor,
                  foregroundColor: AppColor.blackColor, // Icon color, if needed
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColor.blackColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _showResendButton
                ? TextButton(
                    onPressed: _resendEmail,
                    child: const Text('Resend Email'),
                  )
                : Text(
                    'Resend in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                    style: TextStyle(color: AppColor.greyColor),
                  ),
          ],
        ),
      ),
    );
  }
}
*/
