import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompactActionButton extends StatefulWidget {
  final IconData icon;
  final String label;

  final Color labelColor;
  final Color color;
  final VoidCallback? onTap;

  const CompactActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.labelColor = Colors.white,
    required this.color,
    this.onTap,
  });

  @override
  State<CompactActionButton> createState() => _CompactActionButtonState();
}

class _CompactActionButtonState extends State<CompactActionButton> {
  final ValueNotifier<bool> _isPressed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        print('⬇️ Pointer Down at: ${DateTime.now().toString().split(' ')[1]}');
        _isPressed.value = true;
      },
      onPointerUp: (_) {
        print('⬆️ Pointer Up at: ${DateTime.now().toString().split(' ')[1]}');
        _isPressed.value = false;
      },
      onPointerCancel: (_) {
        print(
            '❌ Pointer Cancel at: ${DateTime.now().toString().split(' ')[1]}');
        _isPressed.value = false;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPressed,
        builder: (context, isPressed, child) {
          return AnimatedScale(
            scale: isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: isPressed ? 0.85 : 1.0,
              duration: const Duration(milliseconds: 10),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onTap,
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  splashFactory: InkRipple.splashFactory,
                  child: Ink(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        widget.icon,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color:  widget.labelColor,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
