import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/bottom_nav_helper.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/performance_cubit.dart';
import 'model/performance_model.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PerformanceCubit()..fetchPerformanceData(),
      child: const PerformanceView(),
    );
  }
}

class PerformanceView extends StatefulWidget {
  const PerformanceView({super.key});

  @override
  State<PerformanceView> createState() => _PerformanceViewState();
}

class _PerformanceViewState extends State<PerformanceView>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Performance',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<PerformanceCubit, PerformanceState>(
        builder: (context, state) {
          if (state is PerformanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PerformanceError) {
            return Center(child: Text(state.message));
          } else if (state is PerformanceLoaded) {
            if (state.data.isEmpty) {
              return _buildPremiumEmptyState();
            }
            return _buildGrid(state.data);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGrid(List<Datum> items) {
    final width = MediaQuery.of(context).size.width;
    final padding = 0.0;
    final spacing = 12.0;
    final crossAxisCount = 2;
    final totalSpacing = spacing * (crossAxisCount - 1) + padding * 2;
    final itemWidth = (width - totalSpacing) / crossAxisCount;

    final itemHeight = itemWidth * 0.75;
    final childAspectRatio = itemWidth / itemHeight;

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PerformanceCubit>().fetchPerformanceData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildMetricCard(items[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(Datum item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = isDarkMode
        ? item.backgroundColor.withOpacity(0.15)
        : item.backgroundColor.withOpacity(0.1);

    final Color borderColor = isDarkMode
        ? item.backgroundColor.withOpacity(0.3)
        : item.backgroundColor.withOpacity(0.2);

    final Color displayTextColor = isDarkMode
        ? _getLightShade(item.textColor)
        : _getDarkShade(item.textColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconForLabel(item.label, displayTextColor),
              if (item.today > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: displayTextColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${item.today} Today",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: displayTextColor,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            item.label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: displayTextColor.withOpacity(0.9),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
          ),
          Text(
            "${item.total}",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: displayTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLightShade(Color color) =>
      HSVColor.fromColor(color).withValue(0.9).withSaturation(0.4).toColor();
  Color _getDarkShade(Color color) =>
      HSVColor.fromColor(color).withValue(0.5).withSaturation(0.9).toColor();

  Widget _buildIconForLabel(String label, Color color) {
    IconData icon = Icons.bar_chart;
    label = label.toLowerCase();

    if (label.contains("account")) {
      icon = Icons.business_center_outlined;
    } else if (label.contains("winning"))
      icon = Icons.trending_up;
    else if (label.contains("losing"))
      icon = Icons.trending_down;
    else if (label.contains("open"))
      icon = Icons.pie_chart_outline;
    else if (label.contains("closed"))
      icon = Icons.check_circle_outline;
    else if (label.contains("deposit"))
      icon = Icons.north_east;
    else if (label.contains("withdrawal")) icon = Icons.south_west;

    return Icon(icon, color: color, size: 24);
  }

  Widget _buildPremiumEmptyState() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                context.appBarGradientColor,
                context.appBarGradientColorSecond,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.blackColor.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppFlavorColor.darkPrimary.withOpacity(0.6),
                          AppFlavorColor.darkPrimary.withOpacity(0.2),
                        ]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 32,
                    color: context.tabLabelColor,
                  )),
              const SizedBox(height: 20),
              Text(
                'No trading activity found',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: context.profileIconColor,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select different account or periods to view your performance data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              PremiumAppButton(
                text: 'Start Trading',
                icon: Icons.trending_up_rounded,
                showIcon: true,
                height: 48,
                onPressed: () {
                  BottomNavHelper.goTo(0);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
