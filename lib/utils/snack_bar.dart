import 'package:flutter/material.dart';

class SnackBarService {
  SnackBarService._();

  static final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  static void showSnackBar({
    required String message,
    Color? backgroundColor,
    Gradient? gradient,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) {
      debugPrint('SnackBarService: ScaffoldMessenger not initialized');
      return;
    }

    messenger.hideCurrentSnackBar();

    final Gradient effectiveGradient = gradient ??
        LinearGradient(
          colors: [
            (backgroundColor ?? Colors.black87),
            (backgroundColor ?? Colors.black54),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
        content: _PrettySnackContent(
          message: message,
          textColor: textColor,
          gradient: effectiveGradient,
          icon: icon,
          action: action,
        ),
      ),
    );
  }

  static void showSuccess(String message) {
    showSnackBar(
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.check_circle_rounded,
    );
  }

  static void showError(String message) {
    showSnackBar(
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.error_rounded,
    );
  }

  static void showInfo(String message) {
    showSnackBar(
      message: message,
      gradient: const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.info_rounded,
    );
  }
}

class _PrettySnackContent extends StatelessWidget {
  const _PrettySnackContent({
    required this.message,
    required this.textColor,
    required this.gradient,
    this.icon,
    this.action,
  });

  final String message;
  final Color textColor;
  final Gradient gradient;
  final IconData? icon;
  final SnackBarAction? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 0,
            offset: Offset(0, 10),
            color: Colors.black26,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: textColor, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                action!.onPressed();

                SnackBarService.messengerKey.currentState
                    ?.hideCurrentSnackBar();
              },
              style: TextButton.styleFrom(
                foregroundColor: textColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                visualDensity:
                    const VisualDensity(horizontal: -2, vertical: -2),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: Text(action!.label.toUpperCase()),
            ),
          ],
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';

class SnackBarService {
  SnackBarService._();

  static final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static GlobalKey<ScaffoldMessengerState> get messengerKey => _messengerKey;

  static void showSnackBar({
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    if (_messengerKey.currentState == null) {
      debugPrint('SnackBarService: ScaffoldMessenger not initialized');
      return;
    }

    debugPrint('Showing snack bar: $message');

    _messengerKey.currentState!.hideCurrentSnackBar();

    _messengerKey.currentState!.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  static void showSuccess(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green[700]!,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red[700]!,
      icon: Icons.error,
    );
  }

  static void showInfo(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.blue[700]!,
      icon: Icons.info,
    );
  }
}
*/
