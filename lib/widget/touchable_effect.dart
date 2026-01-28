import 'package:flutter/material.dart';

class TouchableEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown; // How much to scale down (0.0 - 1.0)
  final double opacityDown; // Opacity when pressed (0.0 - 1.0)
  final Duration duration; // Animation duration
  final Curve curve; // Animation curve

  const TouchableEffect({
    Key? key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95, // Default: scale to 95%
    this.opacityDown = 0.7, // Default: 70% opacity
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  State<TouchableEffect> createState() => _TouchableEffectState();
}

class _TouchableEffectState extends State<TouchableEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.opacityDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
