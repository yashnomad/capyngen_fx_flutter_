import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:exness_clone/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/snack_bar.dart';
import 'bloc/registration_bloc.dart';
import 'bloc/registration_event.dart';
import 'bloc/registration_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referController = TextEditingController();

  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _buttonController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _referFocus = FocusNode();

  bool get isLengthValid =>
      _passwordController.text.length >= 8 &&
          _passwordController.text.length <= 15;

  bool get hasUpperLower =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_passwordController.text);

  bool get hasNumbersSpecials =>
      RegExp(r'(?=.*[0-9])(?=.*[!@#\$&*~%^\-_=+(){}[\]|;:<>,.?/])')
          .hasMatch(_passwordController.text);

  bool get allPasswordValid =>
      isLengthValid && hasUpperLower && hasNumbersSpecials;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _passwordController.addListener(_onPasswordChanged);

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _buttonController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _referFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referController.dispose();
    super.dispose();
  }

  // Premium Text Field Widget
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FocusNode focusNode,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    int delay = 0,
  }) {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.only(bottom: 24),
          child: AnimatedBuilder(
            animation: focusNode,
            builder: (context, child) {
              final isFocused = focusNode.hasFocus;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isFocused ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: isFocused
                          ? (context.registerFocusColor)
                          : (context.registerFocusSecondColor),
                      letterSpacing: 0.8,
                    ),
                    child: Text(label),
                  ),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isFocused
                              ? Colors.blue.withOpacity(0.15)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: isFocused ? 20 : 10,
                          offset: Offset(0, isFocused ? 8 : 4),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isFocused
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
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      validator: validator,
                      keyboardType: keyboardType,
                      obscureText: obscureText,
                      maxLength: maxLength,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: context.profileIconColor,
                        letterSpacing: 0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.blue.shade300,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                        ),
                        suffixIcon: suffixIcon != null
                            ? Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: suffixIcon,
                        )
                            : null,
                        counterText: maxLength != null ? '${controller.text.length}/$maxLength' : null,
                        counterStyle: TextStyle(
                          fontSize: 12,
                          color: context.registerFocusSecondColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  // Enhanced Password Requirement Widget
  Widget buildPremiumPasswordRequirement(String text, bool isMet) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isMet
                ? Colors.green.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            border: Border.all(
              color: isMet
                  ? Colors.green.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(isMet),
                  color: isMet ? Colors.green.shade600 : Colors.grey.shade400,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                  child: Text(text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Premium Submit Button
  Widget _buildPremiumButton({required bool isLoading}) {

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _buttonScaleAnimation,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isLoading
                  ? LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade500])
                  : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppFlavorColor.primary,
                  AppFlavorColor.darkPrimary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: isLoading
                      ? Colors.grey.withOpacity(0.3)
                      : AppFlavorColor.shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isLoading ? null : () {
                  _buttonController.forward().then((_) {
                    _buttonController.reverse();
                    _onSubmit();
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  child: isLoading
                      ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Create Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1,
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

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (allPasswordValid) {
        context.read<RegistrationBloc>().add(RegisterUser(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            referedBy: _referController.text.trim().isEmpty
                ? null
                : _referController.text.trim()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.profileScaffoldColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
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
      body: BlocListener<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            SnackBarService.showSuccess(
              state.registerResponse.message ?? 'Registration successful!',
            );
            context.pushNamed('verifyEmail');
            if (state.navigatorPage != null) {
              debugPrint('Navigate to: ${state.navigatorPage}');
            }
          } else if (state is RegistrationFailure) {
            SnackBarService.showError(state.message);
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome! 👋',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: context.profileIconColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please enter your valid information to create your account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Fields
                _buildPremiumTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  focusNode: _nameFocus,
                  keyboardType: TextInputType.name,
                  validator: Validators.validateName,
                ),

                _buildPremiumTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                _buildPremiumTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Create a secure password',
                  focusNode: _passwordFocus,
                  obscureText: _obscurePassword,
                  maxLength: 15,
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      key: ValueKey(_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!allPasswordValid) {
                      return 'Password does not meet requirements';
                    }
                    return null;
                  },
                ),

                // Password Requirements
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      buildPremiumPasswordRequirement(
                        "Use from 8 to 15 characters",
                        isLengthValid,
                      ),
                      const SizedBox(height: 8),
                      buildPremiumPasswordRequirement(
                        "Use both uppercase and lowercase letters",
                        hasUpperLower,
                      ),
                      const SizedBox(height: 8),
                      buildPremiumPasswordRequirement(
                        "Use numbers and special characters",
                        hasNumbersSpecials,
                      ),
                    ],
                  ),
                ),

                _buildPremiumTextField(
                  controller: _referController,
                  label: 'Referred By (Optional)',
                  hint: 'Enter referral code if you have one',
                  focusNode: _referFocus,
                  keyboardType: TextInputType.text,
                ),

                const SizedBox(height: 32),

                // Submit Button
                BlocBuilder<RegistrationBloc, RegistrationState>(
                  builder: (context, state) {
                    final isLoading = state is RegistrationLoading;
                    return _buildPremiumButton(isLoading: isLoading);
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
