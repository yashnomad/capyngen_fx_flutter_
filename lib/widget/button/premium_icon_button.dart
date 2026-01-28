import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/config/flavor_config.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final bool enableGradient;
  final bool enableShadow;
  final bool enableAnimation;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final bool isLoading;
  final bool isDisabled;
  final double elevation;
  final Border? border;

  const PremiumIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 24,
    this.color = Colors.white,
    this.backgroundColor,
    this.gradientColors,
    this.enableGradient = true,
    this.enableShadow = true,
    this.enableAnimation = true,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(12),
    this.tooltip,
    this.isLoading = false,
    this.isDisabled = false,
    this.elevation = 4,
    this.border,
  });

  @override
  State<PremiumIconButton> createState() => _PremiumIconButtonState();
}

class _PremiumIconButtonState extends State<PremiumIconButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.enableAnimation) {
      _initAnimations();
    }
  }

  void _initAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _shimmerController.repeat();
    }

    if (widget.isDisabled && !widget.isLoading) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableAnimation) {
      if (widget.isLoading && !oldWidget.isLoading) {
        _shimmerController.repeat();
      } else if (!widget.isLoading && oldWidget.isLoading) {
        _shimmerController.stop();
        _shimmerController.reset();
      }

      if (widget.isDisabled && !widget.isLoading) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    if (widget.enableAnimation) {
      _scaleController.dispose();
      _shimmerController.dispose();
      _pulseController.dispose();
    }
    super.dispose();
  }

  // Get flavor-based colors
  Color get _primaryColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return AppFlavorColor.primary;
  }

  Color get _iconColor {
    if (widget.color != null) return widget.color!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.enableGradient || widget.backgroundColor != null) {
      return Colors.white;
    }

    return AppFlavorColor.primary;
  }

  List<Color> get _gradientColors {
    if (widget.gradientColors != null) return widget.gradientColors!;

    return AppFlavorColor.buttonGradient;
  }

  Color get _shadowColor {
    return AppFlavorColor.shadowColor;
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
      ),
    );
  }

  Widget _buildShimmerOverlay() {
    if (!widget.isLoading || !widget.enableAnimation) return const SizedBox();

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerAnimation.value, 0.0),
                  end: Alignment(1.0 + _shimmerAnimation.value, 0.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        widget.isDisabled || widget.isLoading || widget.onPressed == null;

    Widget iconButton = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.enableGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDisabled
                    ? [Colors.grey.shade400, Colors.grey.shade500]
                    : _gradientColors,
              )
            : null,
        color: widget.enableGradient
            ? null
            : (isDisabled ? Colors.grey.shade300 : _primaryColor),
        boxShadow: widget.enableShadow
            ? [
                BoxShadow(
                  color:
                      isDisabled ? Colors.grey.withOpacity(0.2) : _shadowColor,
                  blurRadius: widget.elevation * 2,
                  offset: Offset(0, widget.elevation),
                ),
              ]
            : null,
        border: widget.border,
      ),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              onTap: isDisabled
                  ? null
                  : () async {
                      if (widget.enableAnimation) {
                        await _scaleController.forward();
                        _scaleController.reverse();
                      }
                      HapticFeedback.lightImpact();
                      widget.onPressed?.call();
                    },
              child: Container(
                padding: widget.padding,
                child: widget.isLoading
                    ? _buildLoadingIndicator()
                    : Icon(
                        widget.icon,
                        size: widget.size,
                        color: isDisabled ? Colors.grey.shade600 : _iconColor,
                      ),
              ),
            ),
          ),
          _buildShimmerOverlay(),
        ],
      ),
    );

    // Apply animations
    if (widget.enableAnimation) {
      if (widget.isDisabled && !widget.isLoading) {
        iconButton = AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: iconButton,
        );
      }

      iconButton = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: iconButton,
      );
    }

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: iconButton);
    }

    return iconButton;
  }
}
