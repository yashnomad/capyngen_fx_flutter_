import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/network/api_controller.dart';
import 'package:exness_clone/network/api_service.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/auth_screen/login/verify_your_account.dart';
import 'package:flutter/material.dart';

import '../../../widget/button/premium_app_button.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  bool showEmailError = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Focus Node for premium interactions
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Quick entrance animation
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
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
  }

  bool _isLoading = false;
  bool _loader(bool status) {
    setState(() {
      _isLoading = status;
    });

    return _isLoading;
  }

  Future<void> _sendResetLink(String email) async {
    if (email.isEmpty) {
      return;
    }

    try {
      _loader(true);
      final response = await ApiService.forgetPassword({
        'email': email,
      });
      if (response.success) {
        _loader(false);

        // SnackBarService.showSuccess(response.message ??
        //     'Reset password link sent to your email, kindly check your email inbox!');

        if (mounted) {
          showResetPasswordDialog(context);
        }
      } else {
        _loader(false);

        SnackBarService.showSuccess(
            response.message ?? 'Something went wrong!');
      }
    } catch (e) {
      _loader(false);

      SnackBarService.showError(e.toString());
    } finally {
      _loader(false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailFocus.dispose();
    emailController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade100,
                          Colors.red.shade100,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reset Password 🔐',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter your email address and we\'ll send you a link to reset your password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade700,
                          height: 1.4,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumEmailField() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: AnimatedBuilder(
            animation: _emailFocus,
            builder: (context, child) {
              final isFocused = _emailFocus.hasFocus;
              final hasError = showEmailError;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isFocused ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: hasError
                          ? Colors.red.shade600
                          : isFocused
                              ? (context.registerFocusColor)
                              : (context.registerFocusSecondColor),
                      letterSpacing: 0.8,
                    ),
                    child: const Text('Email Address'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: hasError
                              ? Colors.red.withOpacity(0.15)
                              : isFocused
                                  ? Colors.blue.withOpacity(0.15)
                                  : Colors.black.withOpacity(0.08),
                          blurRadius: hasError || isFocused ? 20 : 10,
                          offset: Offset(0, hasError || isFocused ? 8 : 4),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: hasError
                            ? [
                                Colors.red.shade50,
                                Colors.red.shade100.withOpacity(0.5),
                              ]
                            : isFocused
                                ? [
                                    context.appBarGradientColor,
                                    context.appBarGradientColorSecond,
                                  ]
                                : [
                                    context.profileScaffoldColor,
                                    context.appBarGradientColor,
                                  ],
                      ),
                    ),
                    child: TextField(
                      controller: emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: context.profileIconColor,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: hasError
                                ? Colors.red.shade400
                                : Colors.blue.shade400,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: hasError
                              ? BorderSide(color: Colors.red.shade400, width: 1)
                              : BorderSide.none,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.email_outlined,
                            color: hasError
                                ? Colors.red.shade400
                                : isFocused
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (showEmailError && value.trim().isNotEmpty) {
                          setState(() {
                            showEmailError = false;
                          });
                        }
                      },
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Email address is required',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTip() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Tip',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check your spam folder if you don\'t receive the reset email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
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
          'Reset Password',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Header Section
            _buildHeader(),

            // Email Field
            _buildPremiumEmailField(),

            // Security Tip
            _buildSecurityTip(),

            const SizedBox(height: 40),

            // Continue Button
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: PremiumAppButton(
                  text: 'Send Reset Link',
                  icon: Icons.send_rounded,
                  showIcon: true,
                  isLoading: _isLoading,
                  onPressed: () async {
                    final email = emailController.text.trim();

                    setState(() {
                      showEmailError = email.isEmpty;
                    });
                    if (!showEmailError) {
                      await _sendResetLink(email);

                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => VerifyAccountScreen()),
                      // );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void showResetPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Hug content
              children: [
                // 1. Key Icon with Shadow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.vpn_key_outlined,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Title "Reset Your Password"
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial', // Or your app font
                    ),
                    children: [
                      TextSpan(
                        text: "Reset Your ",
                        style: TextStyle(color: Color(0xFF1F2937)),
                      ),
                      TextSpan(
                        text: "Password",
                        style: TextStyle(
                            color: AppFlavorColor.primary), // Orange color
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Subtitle
                const Text(
                  "Check your email for reset instructions",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Success Message Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4), // Light green bg
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF16A34A), // Green icon
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Reset Link Sent!",
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We've sent password reset instructions to your email. Please check your inbox and follow the instructions to reset your password.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.teal[900],
                          height: 1.4,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. "Didn't receive..." text
                const Text(
                  "Didn't receive the email?",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // 6. Try Again Link

                PremiumAppButton(
                  text: 'Try again',
                  onPressed: () => _sendResetLink(emailController.text.trim()),
                  isLoading: _isLoading,
                ),

                // InkWell(
                //   onTap: () {
                //     // Handle Try Again logic
                //   },
                //   child: Text(
                //     "Try again",
                //     style: TextStyle(
                //       color: AppFlavorColor.primary,
                //       fontWeight: FontWeight.bold,
                //       fontSize: 15,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 30),

                // 7. Back to Sign In
                TextButton(
                  onPressed: () => Navigator.of(context)
                    ..pop()
                    ..pop(),
                  child: Text(
                    "Back to Sign In",
                    style: TextStyle(
                      color: AppFlavorColor.primary, // Orange color
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
