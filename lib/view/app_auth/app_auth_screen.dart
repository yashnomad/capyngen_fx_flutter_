import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/app_auth/provider/app_auth_provider.dart';
import 'package:exness_clone/view/app_auth/widget/reset_pin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'widget/auth_num_button.dart';

class AppAuthScreen extends StatefulWidget {
  final bool isResettingPin;
  const AppAuthScreen({super.key, this.isResettingPin = false});

  @override
  State<AppAuthScreen> createState() => _AppAuthScreenState();
}

class _AppAuthScreenState extends State<AppAuthScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final List<String> _pinCode = [];
  final List<String> _confirmPinCode = [];
  final int _pinLength = 4;

  bool _isLoading = false;
  bool _canCheckBiometrics = false;
  bool _isSettingPin = false;
  bool _isConfirmingPin = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _initializeShakeAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedToSetPin();
    });
  }

  void _checkIfNeedToSetPin() {
    final authProvider = context.read<AppAuthProvider>();
    if (!authProvider.hasPinSet) {
      setState(() => _isSettingPin = true);
    }
  }

  void _initializeShakeAnimation() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticOut,
      ),
    );
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      if (mounted) {
        setState(() => _canCheckBiometrics = canCheck && isDeviceSupported);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _canCheckBiometrics = false);
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isSettingPin) return;

    setState(() => _isLoading = true);

    try {
      final authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access the app',
          biometricOnly: false,
          persistAcrossBackgrounding: true,
          sensitiveTransaction: true
          // options: const AuthenticationOptions(
          //   stickyAuth: true,
          //   biometricOnly: false,
          // ),
          );

      if (authenticated && mounted) {
        _onAuthSuccess();
      }
    } on PlatformException catch (e) {
      if (mounted) {
        SnackBarService.showError('Authentication error: ${e.message}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_isSettingPin) {
      if (!_isConfirmingPin) {
        if (_pinCode.length < _pinLength) {
          setState(() => _pinCode.add(number));
          if (_pinCode.length == _pinLength) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() => _isConfirmingPin = true);
              }
            });
          }
        }
      } else {
        if (_confirmPinCode.length < _pinLength) {
          setState(() => _confirmPinCode.add(number));
          if (_confirmPinCode.length == _pinLength) {
            _verifyPinMatch();
          }
        }
      }
    } else {
      if (_pinCode.length < _pinLength) {
        setState(() => _pinCode.add(number));
        if (_pinCode.length == _pinLength) {
          _verifyPin();
        }
      }
    }
  }

  void _onDeletePressed() {
    if (_isConfirmingPin) {
      if (_confirmPinCode.isNotEmpty) {
        setState(() => _confirmPinCode.removeLast());
      }
    } else {
      if (_pinCode.isNotEmpty) {
        setState(() => _pinCode.removeLast());
      }
    }
  }

  Future<void> _verifyPinMatch() async {
    final pin = _pinCode.join();
    final confirmPin = _confirmPinCode.join();

    if (pin == confirmPin) {
      final authProvider = context.read<AppAuthProvider>();
      final saved = await authProvider.savePin(pin);

      if (saved && mounted) {
        SnackBarService.showSuccess('PIN set successfully!');
        setState(() {
          _isSettingPin = false;
          _isConfirmingPin = false;
          _pinCode.clear();
          _confirmPinCode.clear();
        });
        if (widget.isResettingPin) {
          Navigator.pop(context);
        }
      }
    } else {
      _triggerShake();
      SnackBarService.showInfo('PINs do not match. Try again.');
      setState(() {
        _pinCode.clear();
        _confirmPinCode.clear();
        _isConfirmingPin = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authProvider = context.read<AppAuthProvider>();
    final enteredPin = _pinCode.join();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 200));

    final isValid = await authProvider.verifyPin(enteredPin);

    if (mounted) {
      setState(() => _isLoading = false);

      if (isValid) {
        _onAuthSuccess();
      } else {
        _onAuthFailed();
      }
    }
  }

  void _onAuthSuccess() {
    final authProvider = context.read<AppAuthProvider>();
    authProvider.authenticate();
    // SnackBarService.showSuccess('Authentication successful!');
  }

  void _onAuthFailed() {
    _triggerShake();
    setState(() => _pinCode.clear());
    SnackBarService.showError('Incorrect PIN. Please try again.');
  }

  void _triggerShake() {
    _shakeController.forward().then((_) => _shakeController.reverse());
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppFlavorColor.buttonGradient
                // colors: [
                //   const Color(0xFF6C63FF),
                //   const Color(0xFF8B5CF6),
                //   Colors.purple.shade400,
                // ],
                ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                _buildHeader(),
                const SizedBox(height: 30),

                // const Spacer(),
                _buildPinDisplay(),
                const SizedBox(height: 20),
                _buildNumberPad(),
                const SizedBox(height: 20),
                if (_canCheckBiometrics && !_isSettingPin)
                  _buildBiometricButton(),
                // const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;

    if (_isSettingPin) {
      if (_isConfirmingPin) {
        title = 'Confirm PIN';
        subtitle = 'Re-enter your 4-digit PIN';
      } else {
        title = 'Set PIN';
        subtitle = 'Create a 4-digit PIN';
      }
    } else {
      title = 'Enter PIN';
      subtitle = 'Enter your 4-digit PIN to continue';
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPinDisplay() {
    final displayLength =
        _isConfirmingPin ? _confirmPinCode.length : _pinCode.length;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value *
                (_shakeController.status == AnimationStatus.reverse ? -1 : 1),
            0,
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pinLength, (index) {
          final isFilled = index < displayLength;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? Colors.white : Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNumberPad() {
    final numbers = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
        ),
        itemCount: numbers.length,
        itemBuilder: (context, index) {
          final number = numbers[index];
          if (number.isEmpty) return const SizedBox.shrink();
          return AppNumberButton(
            value: number,
            onPressed: _isLoading
                ? null
                : () {
                    if (number == 'delete') {
                      _onDeletePressed();
                    } else {
                      _onNumberPressed(number);
                    }
                  },
          );
        },
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Column(
      children: [
        Text(
          'Or authenticate with',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoading ? null : _authenticateWithBiometrics,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      ),
                    )
                  : const Icon(
                      Icons.fingerprint,
                      size: 40,
                      color: Color(0xFF6C63FF),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HOME SCREEN - Protected screen (user can only access after authentication)
// ============================================================================
class AppHomeScreen extends StatelessWidget {
  const AppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Authentication Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You are now in the protected area',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.read<AppAuthProvider>().logout();
              },
              child: const Text('Logout'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                AppAuthResetPinDialog.showAuthPinResetDialog(context);
              },
              child: const Text('Reset PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
