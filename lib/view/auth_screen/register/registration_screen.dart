import 'package:exness_clone/config/flavor_assets.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:exness_clone/theme/app_flavor_color.dart';
import 'bloc/registration_bloc.dart';
import 'bloc/registration_event.dart';
import 'bloc/registration_state.dart';

// ─── Country Code Model ───────────────────────────────────────────────────────
class _CountryCode {
  final String name;
  final String flag;
  final String dialCode;
  const _CountryCode(this.name, this.flag, this.dialCode);
}

const _kCountries = [
  _CountryCode('India', '🇮🇳', '+91'),
  _CountryCode('United States', '🇺🇸', '+1'),
  _CountryCode('United Kingdom', '🇬🇧', '+44'),
  _CountryCode('United Arab Emirates', '🇦🇪', '+971'),
  _CountryCode('Australia', '🇦🇺', '+61'),
  _CountryCode('Canada', '🇨🇦', '+1'),
  _CountryCode('Germany', '🇩🇪', '+49'),
  _CountryCode('France', '🇫🇷', '+33'),
  _CountryCode('Singapore', '🇸🇬', '+65'),
  _CountryCode('South Africa', '🇿🇦', '+27'),
  _CountryCode('Nigeria', '🇳🇬', '+234'),
  _CountryCode('Pakistan', '🇵🇰', '+92'),
  _CountryCode('Bangladesh', '🇧🇩', '+880'),
  _CountryCode('Indonesia', '🇮🇩', '+62'),
  _CountryCode('Malaysia', '🇲🇾', '+60'),
  _CountryCode('Philippines', '🇵🇭', '+63'),
  _CountryCode('Saudi Arabia', '🇸🇦', '+966'),
  _CountryCode('Qatar', '🇶🇦', '+974'),
  _CountryCode('Kuwait', '🇰🇼', '+965'),
  _CountryCode('Japan', '🇯🇵', '+81'),
  _CountryCode('China', '🇨🇳', '+86'),
  _CountryCode('Brazil', '🇧🇷', '+55'),
  _CountryCode('Mexico', '🇲🇽', '+52'),
  _CountryCode('Russia', '🇷🇺', '+7'),
  _CountryCode('Turkey', '🇹🇷', '+90'),
  _CountryCode('Italy', '🇮🇹', '+39'),
  _CountryCode('Spain', '🇪🇸', '+34'),
  _CountryCode('Netherlands', '🇳🇱', '+31'),
  _CountryCode('Switzerland', '🇨🇭', '+41'),
  _CountryCode('Kenya', '🇰🇪', '+254'),
];

// ─── Registration Screen ──────────────────────────────────────────────────────
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referController = TextEditingController();

  _CountryCode _selectedCountry = _kCountries.first; // India default
  bool _obscurePassword = true;

  Color get _accent => AppFlavorColor.primary;
  Color get _textColor => Colors.black;
  Color get _borderColor => Colors.grey.shade300;

  bool get isLengthValid =>
      _passwordController.text.length >= 8 &&
      _passwordController.text.length <= 15;
  bool get hasUpperLower =>
      RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(_passwordController.text);
  bool get hasNumbersSpecials =>
      RegExp(r'(?=.*[0-9])(?=.*[!@#\$&*~%^\-_=+(){}\[\]|;:<>,.?/])')
          .hasMatch(_passwordController.text);
  bool get allPasswordValid =>
      isLengthValid && hasUpperLower && hasNumbersSpecials;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _referController.dispose();
    super.dispose();
  }

  // ── Country picker bottom sheet ───────────────────────────
  void _showCountryPicker() {
    final searchCtrl = TextEditingController();
    List<_CountryCode> filtered = List.from(_kCountries);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select Country Code',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (q) => setModal(() {
                    filtered = _kCountries
                        .where((c) =>
                            c.name.toLowerCase().contains(q.toLowerCase()) ||
                            c.dialCode.contains(q))
                        .toList();
                  }),
                  decoration: InputDecoration(
                    hintText: 'Search country or dial code…',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: _accent, size: 20),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Country list
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    final sel = c.name == _selectedCountry.name;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCountry = c);
                        Navigator.pop(context);
                      },
                      child: Container(
                        color: sel
                            ? _accent.withOpacity(0.06)
                            : Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87),
                              ),
                            ),
                            Text(
                              c.dialCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: sel ? _accent : Colors.grey.shade600,
                              ),
                            ),
                            if (sel) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_circle,
                                  color: _accent, size: 18),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Phone field with country code ─────────────────────────
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: _textColor),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          validator: (_) {
            if (_phoneController.text.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            if (_phoneController.text.trim().length < 7) {
              return 'Enter a valid phone number';
            }
            return null;
          },
          builder: (field) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: field.hasError ? Colors.red.shade300 : _borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    // Country selector button
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12)),
                          border:
                              Border(right: BorderSide(color: _borderColor)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_selectedCountry.flag,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCountry.dialCode,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: Colors.grey.shade500),
                          ],
                        ),
                      ),
                    ),
                    // Number input
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        onChanged: (_) =>
                            field.didChange(_phoneController.text),
                        style: TextStyle(fontSize: 14, color: _textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade400, fontSize: 14),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 15),
                          border: InputBorder.none,
                          errorStyle: const TextStyle(height: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (field.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    field.errorText!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _textColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          style: TextStyle(fontSize: 14, color: _textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black54, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            counterText: maxLength != null ? '' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey.shade400,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (allPasswordValid) {
        final fullPhone =
            '${_selectedCountry.dialCode}${_phoneController.text.trim()}';
        context.read<RegistrationBloc>().add(RegisterUser(
              fullName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              phone: fullPhone,
              password: _passwordController.text,
              referedBy: _referController.text.trim().isEmpty
                  ? null
                  : _referController.text.trim(),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Create Account",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
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
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Welcome to ${FlavorAssets.appName}!",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please enter your valid information to create\nyour account securely.",
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    keyboardType: TextInputType.name,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email Address",
                    hint: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 20),
                  // ── Phone + Country Code ──
                  _buildPhoneField(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Create a secure password",
                    obscureText: _obscurePassword,
                    maxLength: 15,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
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
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildPasswordRequirement(
                            "Use from 8 to 15 characters", isLengthValid),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement(
                            "Use both uppercase and lowercase letters",
                            hasUpperLower),
                        const SizedBox(height: 8),
                        _buildPasswordRequirement(
                            "Use numbers and special characters",
                            hasNumbersSpecials),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _referController,
                    label: "Referred By (Optional)",
                    hint: "Enter referral code if you have one",
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BlocBuilder<RegistrationBloc, RegistrationState>(
                      builder: (context, state) {
                        final isLoading = state is RegistrationLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Create Account",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed('login'),
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
