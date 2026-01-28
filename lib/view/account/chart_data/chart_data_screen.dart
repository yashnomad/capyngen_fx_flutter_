import 'package:exness_clone/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widget/trading_item.dart';
import 'bloc/market_data_cubit.dart';
import 'bloc/market_data_state.dart';

class BlocChartDataScreen extends StatelessWidget {
  const BlocChartDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketDataCubit()..startFetching(intervalSeconds: 15),
      child: const _ChartDataView(),
    );
  }
}

class _ChartDataView extends StatelessWidget {
  const _ChartDataView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketDataCubit, MarketDataState>(
      builder: (context, state) {
        if (state is MarketDataLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading live market data..."),
                SizedBox(height: 8),
                Text(
                  "Using multiple API keys for continuous updates",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (state is MarketDataError && state.previousData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getErrorIcon(state.message),
                  size: 64,
                  color: _getErrorColor(state.message),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // API Key Controls
                _buildApiKeyControls(context),
              ],
            ),
          );
        }

        if (state is MarketDataLoaded) {
          return Column(
            children: [
              // Enhanced Status Bar with API Key Info
              _buildEnhancedStatusBar(state, context),

              // Warning Banner
              if (state.warning != null) _buildWarningBanner(state.warning!),

              // API Key Status Bar
              _buildApiKeyStatusBar(context),

              // Market Data List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<MarketDataCubit>().refreshData();
                  },
                  child: ListView.builder(
                    itemCount: state.marketData.length,
                    itemBuilder: (context, index) {
                      final item = state.marketData[index];
                      return TradingItem(
                        title: item.symbol.split("/").first,
                        subtitle: item.symbol,
                        price: item.price,
                        change: item.percentChange >= 0
                            ? "↑ ${item.percentChange.toStringAsFixed(2)}%"
                            : "↓ ${item.percentChange.abs().toStringAsFixed(2)}%",
                        chartColor:
                        item.percentChange >= 0 ? Colors.green : Colors.red,
                        flag: "🌐",
                        icon: Icons.currency_exchange,
                        chartData: item.chartData,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        // Fallback
        return const Center(
          child: Text("Something went wrong. Please restart the app."),
        );
      },
    );
  }

  Widget _buildEnhancedStatusBar(MarketDataLoaded state, BuildContext context) {
    final cubit = context.read<MarketDataCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.blue.shade200, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Status Icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(state.isUpdating),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: state.isUpdating
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                state.isUpdating ? Icons.sync : Icons.check_circle,
                size: 16,
                color: state.isUpdating
                    ? Colors.orange.shade700
                    : Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isUpdating ? "Updating..." : "📊 LIVE STOCKS DEMO",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Last update: ${_formatTime(state.lastUpdateTime)}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // API Key Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade300),
            ),
            child: Text(
              "API ${cubit.currentApiKeyIndex}/${cubit.totalApiKeys}",
              style: TextStyle(
                fontSize: 10,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Toggle Auto-Update Button
          _buildToggleButton(cubit, context),
        ],
      ),
    );
  }

  Widget _buildApiKeyStatusBar(BuildContext context) {
    final cubit = context.read<MarketDataCubit>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.purple.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.key, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 8),
          Text(
            "Multi-API Rotation:",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(width: 8),

          // API Key Indicators
          ...List.generate(cubit.totalApiKeys, (index) {
            final isActive = index == cubit.currentApiKeyIndex - 1;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? Colors.purple.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? Colors.purple.shade400 : Colors.purple.shade200,
                ),
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.purple.shade800 : Colors.purple.shade600,
                ),
              ),
            );
          }),

          const Spacer(),

          // Manual Switch Button
          InkWell(
            onTap: () => _showApiKeyDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_horiz, size: 12, color: Colors.purple.shade700),
                  const SizedBox(width: 4),
                  Text(
                    "Switch",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(MarketDataCubit cubit, BuildContext context) {
    return BlocBuilder<MarketDataCubit, MarketDataState>(
      builder: (context, state) {
        final isAutoUpdating = cubit.isAutoUpdating;

        return InkWell(
          onTap: () {
            cubit.toggleAutoUpdate();

            // Show snackbar with feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isAutoUpdating
                      ? "⏸️ Auto-update stopped"
                      : "▶️ Auto-update started (10s intervals)",
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: isAutoUpdating ? Colors.orange : Colors.green,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAutoUpdating ? Colors.orange.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAutoUpdating ? Colors.orange.shade300 : Colors.green.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAutoUpdating ? Icons.pause : Icons.play_arrow,
                  size: 16,
                  color: isAutoUpdating ? Colors.orange.shade700 : Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  isAutoUpdating ? "Stop" : "10s",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAutoUpdating ? Colors.orange.shade700 : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWarningBanner(String warning) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (warning.contains('Switching') || warning.contains('Switched')) {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = Icons.autorenew;
    } else if (warning.contains('API limit') || warning.contains('daily limits')) {
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.warning;
    } else if (warning.contains('Auto-updating')) {
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.autorenew;
    } else if (warning.contains('stopped')) {
      backgroundColor = Colors.grey.shade50;
      textColor = Colors.grey.shade800;
      icon = Icons.pause_circle;
    } else {
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade800;
      icon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: textColor.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyControls(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                context.read<MarketDataCubit>().refreshData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.blueColor,
                foregroundColor: AppColor.whiteColor,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                _showApiKeyDialog(context);
              },
              icon: const Icon(Icons.key),
              label: const Text("Switch API"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: AppColor.whiteColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            context.read<MarketDataCubit>().resetApiKeys();
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Reset to API Key 1"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.greenColor,
            foregroundColor: AppColor.whiteColor,
          ),
        ),
      ],
    );
  }

  void _showApiKeyDialog(BuildContext context) {
    final cubit = context.read<MarketDataCubit>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔑 API Key Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: API Key ${cubit.currentApiKeyIndex}/${cubit.totalApiKeys}'),
            const SizedBox(height: 16),
            const Text('Switch to:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(cubit.totalApiKeys, (index) {
              final isActive = index == cubit.currentApiKeyIndex - 1;
              return ListTile(
                title: Text('API Key ${index + 1}'),
                subtitle: Text(isActive ? 'Currently Active' : 'Available'),
                leading: Icon(
                  isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isActive ? Colors.purple : AppColor.greyColor,
                ),
                onTap: () {
                  cubit.switchToApiKey(index);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🔄 Switched to API Key ${index + 1}'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.resetApiKeys();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('🔄 Reset to API Key 1'),
                  backgroundColor: AppColor.greenColor,
                ),
              );
            },
            child: const Text('Reset to Key 1'),
          ),
        ],
      ),
    );
  }

  IconData _getErrorIcon(String message) {
    if (message.contains('API limit') || message.contains('daily limits')) {
      return Icons.error_outline;
    } else if (message.contains('Network')) {
      return Icons.wifi_off;
    } else {
      return Icons.error_outline;
    }
  }

  Color _getErrorColor(String message) {
    if (message.contains('API limit') || message.contains('daily limits')) {
      return Colors.red.shade400;
    } else if (message.contains('Network')) {
      return Colors.orange.shade400;
    } else {
      return Colors.red.shade400;
    }
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
  }
}