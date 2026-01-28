import 'package:flutter/material.dart';
import '../config/flavor_config.dart';
import '../theme/nestpip_colors.dart';
import '../theme/ellitefx_colors.dart';
import '../theme/pipzo_colors.dart';
import '../theme/capmarket_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
        image: _getBackgroundImage(),
      ),
      child: child,
    );
  }

  /// flavor-wise gradient
  Gradient? _getGradient() {
    switch (FlavorConfig.appFlavor) {
      case Flavor.nestpip:
        return LinearGradient(
          colors: [NestPipColors.gradient1, NestPipColors.gradient2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Flavor.ellitefx:
        return LinearGradient(
          colors: [ElliteFxColors.gradient1, ElliteFxColors.gradient2],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        );
      case Flavor.pipzomarket:
        return LinearGradient(
          colors: [PipzoColors.gradient1, PipzoColors.gradient2],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case Flavor.capmarket:
        return LinearGradient(
          colors: [CapMarketColors.gradient1, CapMarketColors.gradient2],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade200],
        );
    }
  }

  /// flavor-wise image (optional)
  DecorationImage? _getBackgroundImage() {
    switch (FlavorConfig.appFlavor) {
      case Flavor.nestpip:
        return const DecorationImage(
          image: AssetImage("assets/bg/nestpip_bg.png"),
          fit: BoxFit.cover,
        );
      case Flavor.ellitefx:
        return const DecorationImage(
          image: AssetImage("assets/bg/ellitefx_bg.png"),
          fit: BoxFit.cover,
        );
      case Flavor.pipzomarket:
        return const DecorationImage(
          image: AssetImage("assets/bg/pipzo_bg.png"),
          fit: BoxFit.cover,
        );
      case Flavor.capmarket:
        return const DecorationImage(
          image: AssetImage("assets/bg/capmarket_bg.png"),
          fit: BoxFit.cover,
        );
      default:
        return null;
    }
  }
}
