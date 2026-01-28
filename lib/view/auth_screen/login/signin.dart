import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/utils/validators.dart';
import 'package:exness_clone/view/auth_screen/login/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_flavor_color.dart';
import '../../../utils/snack_bar.dart';
import '../../../widget/button/premium_app_button.dart';
import '../../profile/user_profile/bloc/user_profile_bloc.dart';
import '../../profile/user_profile/bloc/user_profile_event.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Focus Nodes for premium interactions
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    emailController.dispose();
    passwordController.dispose();
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
  }) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
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
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                        suffixIcon: suffixIcon != null
                            ? Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: suffixIcon,
                              )
                            : null,
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
              Text(
                'Welcome Back! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: context.profileIconColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your credentials to access your account',
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
    );
  }

  Widget _buildForgotPasswordLink() {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPassword()),
                );
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
                    color: AppFlavorColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Forgot your password?",
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

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      context.read<LoginBloc>().add(LoginRequested(
            email: email,
            password: password,
          ));
    }
  }

  void _handleLoginSuccess(LoginSuccess state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<UserProfileBloc>();
      bloc.add(FetchUserProfile());
      SnackBarService.showSuccess(state.message);
    });

    final user = state.user;
    debugPrint('Welcome ${user.fullName}!');
    debugPrint('Account ID: ${user.accountId}');
    debugPrint('KYC Status: ${user.kycStatus}');
    debugPrint('Verification Status: ${state.verificationStatus}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (state.navigatorPage) {
        case '/dashboard':
          context.goNamed('appAuthGate');
          // context.goNamed('home');
          break;
        case '/verify-email':
          context.goNamed('verifyEmail');
          break;
        case '/kyc-status':
          context.goNamed('kycStatus');
          break;
        case '/kyc-verification':
          context.goNamed('kycVerification');
          break;
        default:
          context.goNamed('auth');
          break;
      }
    });
  }

  void _handleLoginFailure(LoginFailure state) {
    debugPrint("🔥 Login failed: ${state.error}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackBarService.showError(state.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: context.appBarIconBrightness,
        title: Text(
          'Sign In',
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
              color: context.boxDecorationColor,
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
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            _handleLoginSuccess(state);
          } else if (state is LoginFailure) {
            _handleLoginFailure(state);
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Header Section
                _buildHeader(),

                // Email Field
                _buildPremiumTextField(
                  controller: emailController,
                  label: 'Email Address',
                  hint: 'Enter your email address',
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),

                // Password Field
                _buildPremiumTextField(
                  controller: passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  focusNode: _passwordFocus,
                  obscureText: isPasswordHidden,
                  validator: Validators.validatePassword,
                  suffixIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      key: ValueKey(isPasswordHidden),
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Sign In Button
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        final isLoading = state is LoginLoading;
                        return PremiumAppButton(
                          text: 'Sign In',
                          isLoading: isLoading,
                          icon: Icons.login_rounded,
                          showIcon: true,
                          onPressed: isLoading ? null : _validateAndLogin,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Forgot Password Link
                _buildForgotPasswordLink(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
import 'package:exness_clone/utils/validators.dart';
import 'package:exness_clone/view/auth_screen/auth_screen.dart';
import 'package:exness_clone/view/auth_screen/login/reset_password.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/loader.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/snack_bar.dart';
import '../../home_page/home_page_screen.dart';
import '../../profile/user_profile/bloc/user_profile_bloc.dart';
import '../../profile/user_profile/bloc/user_profile_event.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';
import 'reset_password_second.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordHidden = true;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _validateAndLogin() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      context.read<LoginBloc>().add(LoginRequested(
            email: email,
            password: password,
          ));
    }
  }

  void _handleLoginSuccess(LoginSuccess state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<UserProfileBloc>();
      bloc.add(FetchUserProfile());
      SnackBarService.showSuccess(state.message);
    });

    final user = state.user;
    debugPrint('Welcome ${user.fullName}!');
    debugPrint('Account ID: ${user.accountId}');
    debugPrint('KYC Status: ${user.kycStatus}');
    debugPrint('Verification Status: ${state.verificationStatus}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (state.navigatorPage) {
        case '/dashboard':
          context.goNamed('home');
          break;
        case '/verify-email':
          context.goNamed('verifyEmail');
          break;
        case '/kyc-status':
          context.goNamed('kycStatus');
          break;
        case '/kyc-verification':
          context.goNamed('kycVerification');
          break;
        default:
          context.goNamed('auth');
          break;

      }
    });
  }

  void _handleLoginFailure(LoginFailure state) {
    debugPrint("🔥 Login failed: ${state.error}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SnackBarService.showError(state.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Sign In'),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            _handleLoginSuccess(state);
          } else if (state is LoginFailure) {
            _handleLoginFailure(state);
          }
        },
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please enter your email address and password",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Email",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.mediumGrey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.redColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.redColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Password",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: isPasswordHidden,
                  validator: Validators.validatePassword,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.mediumGrey),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.redColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.redColor, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Spacer(),
                BlocBuilder<LoginBloc, LoginState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          state is LoginLoading ? null : _validateAndLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FlavorConfig.appFlavor == Flavor.nestpip? AppColor.nestPipColor: FlavorConfig.appFlavor == Flavor.ellitefx?AppColor.elliteFxColor:FlavorConfig.appFlavor == Flavor.pipzomarket?AppColor.pipzoColor: AppColor.yellowColor,
                        foregroundColor:FlavorConfig.appFlavor == Flavor.nestpip? AppColor.whiteColor: FlavorConfig.appFlavor == Flavor.ellitefx?AppColor.whiteColor :FlavorConfig.appFlavor == Flavor.pipzomarket?AppColor.whiteColor: AppColor.blackColor,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: state is LoginLoading
                          ? Loader()
                          : Text(
                              "Sign in",
                              style: TextStyle(

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResetPassword()),
                      );
                    },
                    child: const Text(
                      "I forgot my password",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
