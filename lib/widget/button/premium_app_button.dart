import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/theme/capmarket_colors.dart';
import 'package:exness_clone/theme/prime_forex_color.dart';
import 'package:exness_clone/theme/right_trade_color.dart';
import 'package:flutter/material.dart';
import '../../config/flavor_config.dart';
import '../../theme/ellitefx_colors.dart';
import '../../theme/nestpip_colors.dart';
import '../../theme/pipzo_colors.dart';

class PremiumAppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final IconData? icon;
  final bool showIcon;
  final ButtonStyle? customStyle;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final List<Color>? gradientColors;
  final bool enableGradient;
  final bool enableShadow;
  final bool enableAnimation;
  final double elevation;

  const PremiumAppButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius = 16,
    this.icon,
    this.showIcon = false,
    this.customStyle,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.gradientColors,
    this.enableGradient = true,
    this.enableShadow = true,
    this.enableAnimation = true,
    this.elevation = 8,
  });

  @override
  State<PremiumAppButton> createState() => _PremiumAppButtonState();
}

class _PremiumAppButtonState extends State<PremiumAppButton>
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
    // Scale animation for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Shimmer animation for loading state
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation for disabled state
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
  void didUpdateWidget(PremiumAppButton oldWidget) {
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

  Color get _foregroundColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;

    return AppFlavorColor.background;
  }

  /* List<Color> get _gradientColors {
      if (widget.gradientColors != null) return widget.gradientColors!;

      switch (FlavorConfig.appFlavor) {
        case Flavor.nestpip:
          return [Colors.blue.shade600, Colors.blue.shade700];
        case Flavor.ellitefx:
          return [Colors.purple.shade600, Colors.purple.shade700];
        case Flavor.pipzomarket:
          return [Colors.orange.shade600, Colors.orange.shade700];
        default:
          return [Colors.amber.shade500, Colors.amber.shade600];
      }
    }*/
  //
  // List<Color> get _gradientColors {
  //   if (widget.gradientColors != null) return widget.gradientColors!;
  //
  //   switch (FlavorConfig.appFlavor) {
  //     case Flavor.ellitefx:
  //       return [ElliteFxColors.primary, ElliteFxColors.primaryDark];
  //     case Flavor.nestpip:
  //       return [NestPipColors.primary, NestPipColors.primaryDark];
  //     case Flavor.pipzomarket:
  //       return [PipzoColors.primary, PipzoColors.primaryDark];
  //     case Flavor.primeforex:
  //       return [PrimeForexColors.primary, PrimeForexColors.primaryDark];
  //     case Flavor.capmarket:
  //       return [CapMarketColors.primary, CapMarketColors.primaryDark];
  //     case Flavor.righttrade:
  //       return [RightTradeColors.primary, RightTradeColors.primaryDark];
  //     default:
  //       return [Colors.grey.shade600, Colors.grey.shade700];
  //   }
  // }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(_foregroundColor),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return _buildLoadingIndicator();
    }

    if (widget.showIcon && widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: _foregroundColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.text,
              style: widget.textStyle ??
                  TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: _foregroundColor,
                      letterSpacing: 1,
                      overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: widget.textStyle ??
          TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: _foregroundColor,
            letterSpacing: 1,
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
                    AppColor.transparent,
                    AppColor.whiteColor.withOpacity(0.2),
                    AppColor.transparent,
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

    Widget button = Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: widget.enableGradient
            ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDisabled
              ? [Colors.grey.shade400, Colors.grey.shade500]
              :
            // AppFlavorColor.primary, AppFlavorColor.darkPrimary
            AppFlavorColor.buttonGradient
          ,
        )
            : null,
        color: widget.enableGradient
            ? null
            : (isDisabled ? Colors.grey.shade400 : _primaryColor),
        boxShadow: widget.enableShadow
            ? [
          BoxShadow(
              color: isDisabled
                  ? AppColor.greyColor.withOpacity(0.3)
                  : AppFlavorColor.shadowColor,
              blurRadius: 20,
              offset: Offset(0, widget.elevation))
        ]
            : null,
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
                widget.onPressed?.call();
              },
              child: Container(
                alignment: Alignment.center,
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildButtonContent(),
              ),
            ),
          ),
          _buildShimmerOverlay(),
        ],
      ),
    );

    if (!widget.enableAnimation) {
      return button;
    }

    // Apply animations based on state
    if (widget.isDisabled && !widget.isLoading) {
      button = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: button,
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: button,
    );
  }
}

// Extension for easy usage with different button variants
extension PremiumAppButtonVariants on PremiumAppButton {
  // Primary Button
  static PremiumAppButton primary({
    Key? key,
    VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    IconData? icon,
    bool showIcon = false,
  }) {
    return PremiumAppButton(
      key: key,
      onPressed: onPressed,
      text: text,
      isLoading: isLoading,
      icon: icon,
      showIcon: showIcon,
      enableGradient: true,
      enableShadow: true,
      enableAnimation: true,
    );
  }

  // Secondary Button (outlined)
  static PremiumAppButton secondary({
    Key? key,
    VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    IconData? icon,
    bool showIcon = false,
  }) {
    return PremiumAppButton(
      key: key,
      onPressed: onPressed,
      text: text,
      isLoading: isLoading,
      icon: icon,
      showIcon: showIcon,
      enableGradient: false,
      backgroundColor: AppFlavorColor.primary,
      enableShadow: false,
      enableAnimation: true,
    );
  }

  // Minimal Button
  static PremiumAppButton minimal({
    Key? key,
    VoidCallback? onPressed,
    required String text,
    bool isLoading = false,
    IconData? icon,
    bool showIcon = false,
  }) {
    return PremiumAppButton(
      key: key,
      onPressed: onPressed,
      text: text,
      isLoading: isLoading,
      icon: icon,
      showIcon: showIcon,
      enableGradient: false,
      backgroundColor: Colors.grey.shade100,
      foregroundColor: Colors.grey.shade700,
      enableShadow: false,
      borderRadius: 8,
      height: 44,
    );
  }
}

// Usage Examples:
/*
// Basic usage
PremiumAppButton(
  text: 'Create Account',
  onPressed: () => print('Button pressed!'),
)

// With loading state
PremiumAppButton(
  text: 'Processing...',
  isLoading: true,
  onPressed: () {},
)

  // With icon
  PremiumAppButton(
    text: 'Continue',
    icon: Icons.arrow_forward,
    showIcon: true,
    onPressed: () {},
  )

// Custom styling
PremiumAppButton(
  text: 'Custom Button',
  backgroundColor: Colors.red,
  foregroundColor: Colors.white,
  borderRadius: 8,
  height: 48,
  onPressed: () {},
)

// Using variants
PremiumAppButtonVariants.primary(
  text: 'Primary Action',
  onPressed: () {},
)

PremiumAppButtonVariants.secondary(
  text: 'Secondary Action',
  onPressed: () {},
)

PremiumAppButtonVariants.minimal(
  text: 'Minimal Action',
  onPressed: () {},
)
*/