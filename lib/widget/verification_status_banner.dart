import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../view/profile/user_profile/bloc/user_profile_bloc.dart';
import '../view/profile/user_profile/bloc/user_profile_state.dart';

class VerificationStatusBanner extends StatefulWidget {
  const VerificationStatusBanner({super.key});

  @override
  State<VerificationStatusBanner> createState() =>
      _VerificationStatusBannerState();
}

class _VerificationStatusBannerState extends State<VerificationStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _visible = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showRejectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade600, size: 28),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Verification Rejected',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'Your identity verification was rejected. Please review your documents and submit again.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.push('/kycVerification');
            },
            child: const Text(
              'Try to Submit Again',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        debugPrint('🔍 [VerificationBanner] Bloc state: ${state.runtimeType}');
        if (state is! UserProfileLoaded) return const SizedBox.shrink();

        final status = state.profile.profile?.kycStatus ?? 'pending';
        final hasDocuments = state.profile.profile?.documentType?.value != null;
        debugPrint(
            '🔍 [VerificationBanner] KYC Status: $status, hasDocuments: $hasDocuments');

        // Don't show the banner if already verified
        if (status == 'verified') return const SizedBox.shrink();

        if (!_visible) return const SizedBox.shrink();

        // Determine effective status for display
        // If status is 'pending' but documents exist, show as "under review"
        final effectiveStatus =
            (status == 'pending' && hasDocuments) ? 'under_review' : status;

        final _BannerStyle style = _getBannerStyle(effectiveStatus);

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: () => _handleBannerTap(context, status, hasDocuments),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: style.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: style.gradientColors.first.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Circular progress indicator
                      CircularPercentIndicator(
                        radius: 22,
                        lineWidth: 3.5,
                        percent: style.progress,
                        center: Text(
                          style.stepText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        progressColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 14),

                      // Text content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              style.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              style.subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Action button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              style.buttonIcon,
                              size: 14,
                              color: style.buttonTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              style.buttonText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: style.buttonTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBannerTap(
      BuildContext context, String status, bool hasDocuments) {
    switch (status) {
      case 'rejected':
        context.push('/kycVerification');
        break;
      case 'under_review':
        context.push('/kycStatus');
        break;
      case 'pending':
        if (hasDocuments) {
          // Docs submitted but still pending = under review
          context.push('/kycStatus');
        } else {
          // No docs yet = go to verification flow
          context.push('/kycVerification');
        }
        break;
      default:
        context.push('/kycVerification');
    }
  }

  _BannerStyle _getBannerStyle(String status) {
    switch (status) {
      case 'rejected':
        return _BannerStyle(
          gradientColors: [
            const Color(0xFFE53E3E),
            const Color(0xFFC53030),
          ],
          title: 'Rejected',
          subtitle:
              'Your identity verification was rejected. Please submit your documents again.',
          buttonText: 'Apply Again',
          buttonIcon: Icons.refresh_rounded,
          buttonTextColor: const Color(0xFFE53E3E),
          progress: 0.25,
          stepText: '!',
        );
      case 'under_review':
        return _BannerStyle(
          gradientColors: [
            const Color(0xFF3182CE),
            const Color(0xFF2B6CB0),
          ],
          title: 'Verification Under Review',
          subtitle:
              'Your documents are being reviewed. This usually takes 24-48 hours.',
          buttonText: 'Check Status',
          buttonIcon: Icons.hourglass_top_rounded,
          buttonTextColor: const Color(0xFF3182CE),
          progress: 0.75,
          stepText: '3/4',
        );
      case 'pending':
      default:
        return _BannerStyle(
          gradientColors: [
            const Color(0xFFD4A017),
            const Color(0xFFB8860B),
          ],
          title: 'Complete Your Identity Verification',
          subtitle:
              'Unlock higher transaction limits, gain access to new payment methods, and enable additional trading accounts',
          buttonText: 'Verify Now',
          buttonIcon: Icons.verified_outlined,
          buttonTextColor: const Color(0xFFD4A017),
          progress: 0.5,
          stepText: '1/2',
        );
    }
  }
}

class _BannerStyle {
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData buttonIcon;
  final Color buttonTextColor;
  final double progress;
  final String stepText;

  const _BannerStyle({
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.buttonIcon,
    required this.buttonTextColor,
    required this.progress,
    required this.stepText,
  });
}
