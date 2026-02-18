import 'dart:io';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';

import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart'
    as eq_data;
import 'package:exness_clone/view/account/trade_screen/widget/modify_trade.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../provider/datafeed_provider.dart';
import '../../../services/data_feed_ws.dart' as feed_ws;
import '../../../services/switch_account_service.dart';
import '../../../services/trade_pdf_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_flavor_color.dart';
import '../buy_sell_trade/cubit/trade_cubit.dart';
import '../buy_sell_trade/cubit/trade_state.dart';
import '../buy_sell_trade/model/trade_model.dart';
import '../widget/account_symbol_section.dart';
import '../../trade/model/trade_account.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final int _tabIndex = 3;
  String? _lastFetchedAccountId;

  final Set<String> _expandedPositions = {};

  final Color _bgDark = const Color(0xFF161A1E);
  final Color _cardDark = const Color(0xFF1E2329);
  final Color _textGreyDark = const Color(0xFF848E9C);
  final Color _dividerDark = const Color(0xFF2B3139);
  final Color _binanceGreen = const Color(0xFF0ECB81);
  final Color _binanceRed = const Color(0xFFF6465D);

  final Color _bgLight = const Color(0xFFF5F5F5);
  final Color _cardLight = const Color(0xFFFFFFFF);
  final Color _textGreyLight = const Color(0xFF707A8A);
  final Color _dividerLight = const Color(0xFFE6E8EA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: _tabIndex, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('📱 App resumed — reconnecting...');

      if (_lastFetchedAccountId != null) {
        final jwt = StorageService.getToken();

        if (jwt != null) {
          context.read<TradeCubit>().startSocket(
                jwt: jwt,
                userId: _lastFetchedAccountId!,
              );
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.read<TradeCubit>().fetchOpenTrades(_lastFetchedAccountId!);
            context
                .read<TradeCubit>()
                .fetchHistoryTrades(_lastFetchedAccountId!);
          }
        });
      }
    }
  }

  void _fetchDataForAccount(String accountId, {bool forceRefresh = false}) {
    if (!forceRefresh && _lastFetchedAccountId == accountId) {
      return;
    }
    _lastFetchedAccountId = accountId;
    final jwt = StorageService.getToken();

    context.read<TradeCubit>().fetchOpenTrades(accountId);
    context.read<TradeCubit>().fetchHistoryTrades(accountId);

    if (jwt != null) {
      context.read<TradeCubit>().startSocket(jwt: jwt, userId: accountId);
    }
  }

  Future<void> _downloadPdf(
    BuildContext context,
    List<TradeModel> trades,
    String accountId,
  ) async {
    try {
      SnackBarService.showSuccess("Generating PDF...");
      final path = await TradePdfService.saveTradeHistoryPdf(
        trades: trades,
        accountId: accountId,
      );
      SnackBarService.showSuccess("Saved in Downloads:\n$path");
    } catch (e) {
      SnackBarService.showError("Failed to generate PDF");
    }
  }

  void _toggleExpanded(String? tradeId) {
    if (tradeId == null) return;
    setState(() {
      if (_expandedPositions.contains(tradeId)) {
        _expandedPositions.remove(tradeId);
      } else {
        _expandedPositions.add(tradeId);
      }
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✅ ANIMATED CONNECTION STATUS BADGE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildConnectionBadge(ConnectionStatus status, bool isDark) {
    Color dotColor;
    Color bgColor;
    Color textColor;
    String label;
    bool shouldPulse;

    switch (status) {
      case ConnectionStatus.live:
        dotColor = _binanceGreen;
        bgColor = _binanceGreen.withOpacity(0.12);
        textColor = _binanceGreen;
        label = "Live";
        shouldPulse = false;
        break;
      case ConnectionStatus.connecting:
        dotColor = Colors.amber;
        bgColor = Colors.amber.withOpacity(0.12);
        textColor = Colors.amber;
        label = "Connecting";
        shouldPulse = true;
        break;
      case ConnectionStatus.disconnected:
        dotColor = _binanceRed;
        bgColor = _binanceRed.withOpacity(0.12);
        textColor = _binanceRed;
        label = "Disconnected";
        shouldPulse = false;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(status),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dotColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedDot(
              color: dotColor,
              shouldPulse: shouldPulse,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark ? _bgDark : _bgLight;
    final Color cardColor = isDark ? _cardDark : _cardLight;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color greyText = isDark ? _textGreyDark : _textGreyLight;
    final Color dividerColor = isDark ? _dividerDark : _dividerLight;

    return SafeArea(
      child: SwitchAccountService(
        accountBuilder: (context, activeAccount) {
          if (activeAccount.id != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchDataForAccount(activeAccount.id!);
            });
          }

          return Scaffold(
            backgroundColor: bgColor,
            body: BlocListener<TradeCubit, TradeState>(
              listenWhen: (prev, curr) =>
                  prev.successMessage != curr.successMessage ||
                  prev.errorMessage != curr.errorMessage,
              listener: (context, state) {
                if (state.successMessage != null) {
                  SnackBarService.showSuccess(state.successMessage!);
                }
                if (state.errorMessage != null) {
                  SnackBarService.showError(state.errorMessage!);
                }
              },
              child: RefreshIndicator(
                color: AppFlavorColor.primary,
                backgroundColor: cardColor,
                onRefresh: () async {
                  if (activeAccount.id != null) {
                    _fetchDataForAccount(activeAccount.id!, forceRefresh: true);
                    await Future.delayed(const Duration(milliseconds: 500));
                  }
                },
                child: NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 24, 16, 10),
                              color: bgColor,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Positions',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppFlavorColor.primary
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: AppFlavorColor
                                                        .primary
                                                        .withOpacity(0.3)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .account_balance_wallet,
                                                      size: 12,
                                                      color: AppFlavorColor
                                                          .primary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    "Acc #${activeAccount.accountId}",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppFlavorColor
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            BlocBuilder<TradeCubit, TradeState>(
                                              buildWhen: (prev, curr) =>
                                                  prev.connectionStatus !=
                                                  curr.connectionStatus,
                                              builder: (context, state) {
                                                return _buildConnectionBadge(
                                                    state.connectionStatus,
                                                    isDark);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<TradeCubit, TradeState>(
                                builder: (context, state) {
                              return _buildBinanceTopCard(
                                  context,
                                  state,
                                  activeAccount,
                                  cardColor,
                                  textColor,
                                  greyText,
                                  dividerColor);
                            }),
                          ],
                        ),
                      ),
                      SliverAppBar(
                        pinned: true,
                        toolbarHeight: 0,
                        collapsedHeight: 0,
                        expandedHeight: 0,
                        backgroundColor: bgColor,
                        bottom: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          labelStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          unselectedLabelStyle: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                          indicatorSize: TabBarIndicatorSize.label,
                          indicatorWeight: 3,
                          indicatorColor: AppFlavorColor.primary,
                          labelColor: textColor,
                          unselectedLabelColor: greyText,
                          dividerColor: dividerColor,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          tabs: const [
                            Tab(text: "Active"),
                            Tab(text: "Pending"),
                            Tab(text: "History"),
                          ],
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      // ─── ACTIVE TAB ───
                      BlocBuilder<TradeCubit, TradeState>(
                        buildWhen: (previous, current) =>
                            previous.activeTrades != current.activeTrades ||
                            previous.equity != current.equity,
                        builder: (context, state) {
                          final hasActiveTrades = state.activeTrades.isNotEmpty;

                          if (!hasActiveTrades) {
                            return _buildNoOrderUI(context, 'No Open Positions',
                                isDark, cardColor, greyText);
                          }

                          return RefreshIndicator(
                            color: AppFlavorColor.primary,
                            backgroundColor: cardColor,
                            onRefresh: () async {
                              if (activeAccount.id != null) {
                                _fetchDataForAccount(activeAccount.id!,
                                    forceRefresh: true);
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                              }
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: state.activeTrades.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final trade = state.activeTrades[index];

                                final liveProfit =
                                    state.equity?.liveProfit.firstWhere(
                                          (element) => element.id == trade.id,
                                          orElse: () => eq_data.LiveProfit(
                                            id: trade.id,
                                            profit: trade.currentProfit ??
                                                trade.profitLossAmount ??
                                                0.0,
                                            avg: trade.avg,
                                          ),
                                        ) ??
                                        eq_data.LiveProfit(
                                            id: trade.id,
                                            profit: trade.currentProfit ??
                                                trade.profitLossAmount ??
                                                0.0);

                                return _buildCollapsiblePositionCard(
                                    context,
                                    state,
                                    trade,
                                    liveProfit,
                                    activeAccount,
                                    cardColor,
                                    textColor,
                                    greyText,
                                    dividerColor,
                                    isDark);
                              },
                            ),
                          );
                        },
                      ),
                      // ─── PENDING TAB ───
                      BlocBuilder<TradeCubit, TradeState>(
                          buildWhen: (previous, current) =>
                              previous.pendingTrades != current.pendingTrades,
                          builder: (context, state) {
                            if (state.pendingTrades.isEmpty) {
                              return _buildNoOrderUI(
                                  context,
                                  'No Pending Orders',
                                  isDark,
                                  cardColor,
                                  greyText);
                            }
                            return RefreshIndicator(
                              color: AppFlavorColor.primary,
                              backgroundColor: cardColor,
                              onRefresh: () async {
                                if (activeAccount.id != null) {
                                  _fetchDataForAccount(activeAccount.id!,
                                      forceRefresh: true);
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                }
                              },
                              child: ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: state.pendingTrades.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final trade = state.pendingTrades[index];
                                  return _buildCustomPendingCard(
                                      context,
                                      trade,
                                      activeAccount,
                                      cardColor,
                                      textColor,
                                      greyText,
                                      dividerColor,
                                      isDark);
                                },
                              ),
                            );
                          }),
                      // ─── HISTORY TAB ───
                      BlocBuilder<TradeCubit, TradeState>(
                        buildWhen: (previous, current) =>
                            previous.historyTrades != current.historyTrades,
                        builder: (context, state) {
                          if (state.historyTrades.isEmpty) {
                            return _buildNoOrderUI(context, 'No Order History',
                                isDark, cardColor, greyText);
                          }
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (activeAccount.id != null) {
                                          await _downloadPdf(
                                              context,
                                              state.historyTrades,
                                              activeAccount.id!);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Icon(Icons.picture_as_pdf,
                                                color: AppFlavorColor.primary,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            Text("Export PDF",
                                                style: TextStyle(
                                                    color:
                                                        AppFlavorColor.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: RefreshIndicator(
                                  color: AppFlavorColor.primary,
                                  backgroundColor: cardColor,
                                  onRefresh: () async {
                                    if (activeAccount.id != null) {
                                      _fetchDataForAccount(activeAccount.id!,
                                          forceRefresh: true);
                                      await Future.delayed(
                                          const Duration(milliseconds: 500));
                                    }
                                  },
                                  child: ListView.separated(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    itemCount: state.historyTrades.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final trade = state.historyTrades[index];
                                      return _buildCustomHistoryCard(
                                          trade,
                                          cardColor,
                                          textColor,
                                          greyText,
                                          dividerColor,
                                          isDark);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBinanceTopCard(
      BuildContext context,
      TradeState state,
      Account activeAccount,
      Color cardColor,
      Color textColor,
      Color greyText,
      Color dividerColor) {
    final bool hasActiveTrades = state.activeTrades.isNotEmpty;

    final acctBalanceStr = activeAccount.balance?.toString() ?? "0.00";
    final double acctBalDouble = double.tryParse(acctBalanceStr) ?? 0.0;
    final String formattedBalance = acctBalDouble.toStringAsFixed(2);

    String balance = state.equity?.balance ?? formattedBalance;
    String equity = state.equity?.equity ?? formattedBalance;
    String pnl = state.equity?.pnl ?? "0.00";
    String usedMargin = state.equity?.usedMargin ?? "0.00";
    String freeMargin = state.equity?.freeMargin ?? formattedBalance;

    if (!hasActiveTrades) {
      pnl = "0.00";
      usedMargin = "0.00";
      equity = balance;
      freeMargin = balance;
    }

    final double pnlVal = double.tryParse(pnl) ?? 0.0;

    final pnlColor = (!hasActiveTrades || pnlVal == 0)
        ? greyText
        : (pnlVal > 0 ? _binanceGreen : _binanceRed);
    final String pnlDisplay = (!hasActiveTrades || pnlVal == 0)
        ? "0.00"
        : (pnlVal > 0 && !pnl.startsWith('+') ? "+$pnl" : pnl);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopCardStat(
                  "Unrealized PNL (USD)", pnlDisplay, pnlColor, greyText,
                  isLarge: true),
              _buildTopCardStat("Equity", equity, textColor, greyText,
                  isLarge: true, alignRight: true),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopCardStat("Balance", balance, textColor, greyText),
              _buildTopCardStat("Used Margin", usedMargin, textColor, greyText),
              _buildTopCardStat("Free Margin", freeMargin, textColor, greyText,
                  alignRight: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCardStat(
      String label, String value, Color valColor, Color greyText,
      {bool isLarge = false, bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: greyText, fontSize: isLarge ? 12 : 11)),
        SizedBox(height: isLarge ? 4 : 2),
        Text(value,
            style: TextStyle(
                color: valColor,
                fontSize: isLarge ? 20 : 14,
                fontWeight: isLarge ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _buildCollapsiblePositionCard(
      BuildContext context,
      TradeState state,
      TradeModel trade,
      eq_data.LiveProfit liveProfit,
      Account activeAccount,
      Color cardColor,
      Color textColor,
      Color greyText,
      Color dividerColor,
      bool isDark) {
    final isBuy = (trade.bs ?? 'Buy').toLowerCase() == 'buy';
    final sideColor = isBuy ? _binanceGreen : _binanceRed;

    final bool isConnecting = state.equity == null;

    final pnlVal = liveProfit.profit ??
        trade.currentProfit ??
        trade.profitLossAmount ??
        0.0;

    final bool showDashes = isConnecting &&
        trade.currentProfit == null &&
        (trade.profitLossAmount == null || trade.profitLossAmount == 0.0);

    final pnlColor =
        showDashes ? greyText : (pnlVal >= 0 ? _binanceGreen : _binanceRed);
    final pnlStr = showDashes
        ? "--"
        : "${pnlVal >= 0 ? '+' : ''}${pnlVal.toStringAsFixed(2)}";

    const leverage = 20;
    final lotSize = trade.lot ?? 0.0;
    final entryPrice = trade.avg ?? 0.0;
    final marginCalc = (lotSize * entryPrice) / leverage;

    final tpStr =
        trade.target != null ? trade.target!.toStringAsFixed(2) : "--";
    final slStr = trade.sl != null ? trade.sl!.toStringAsFixed(2) : "--";

    final String tradeKey = trade.id ?? trade.hashCode.toString();
    final bool isExpanded = _expandedPositions.contains(tradeKey);

    return GestureDetector(
      onTap: () => _toggleExpanded(tradeKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isExpanded
              ? Border.all(color: sideColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      color: sideColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(isBuy ? "B" : "S",
                      style: TextStyle(
                          color: sideColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Text(trade.symbol ?? "Unknown",
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4)),
                  child: Text("${leverage}x",
                      style: TextStyle(color: greyText, fontSize: 11)),
                ),
                const SizedBox(width: 12),
                Text(pnlStr,
                    style: TextStyle(
                        color: pnlColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: greyText, size: 22),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(
                context,
                state,
                trade,
                liveProfit,
                activeAccount,
                isBuy,
                sideColor,
                pnlStr,
                pnlColor,
                lotSize,
                entryPrice,
                marginCalc,
                tpStr,
                slStr,
                leverage,
                cardColor,
                textColor,
                greyText,
                dividerColor,
                isDark,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    TradeState state,
    TradeModel trade,
    eq_data.LiveProfit liveProfit,
    Account activeAccount,
    bool isBuy,
    Color sideColor,
    String pnlStr,
    Color pnlColor,
    double lotSize,
    double entryPrice,
    double marginCalc,
    String tpStr,
    String slStr,
    int leverage,
    Color cardColor,
    Color textColor,
    Color greyText,
    Color dividerColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Unrealized PNL (USDT)",
                    style: TextStyle(color: greyText, fontSize: 12)),
                const SizedBox(height: 4),
                Text(pnlStr,
                    style: TextStyle(
                        color: pnlColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            _buildGridStat("TP / SL", "$tpStr / $slStr", textColor, greyText),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildGridStat("Size", lotSize.toString(), textColor, greyText),
            _buildGridStat(
                "Margin", marginCalc.toStringAsFixed(2), textColor, greyText),
            _buildGridStat("Entry Price", entryPrice.toStringAsFixed(2),
                textColor, greyText),
            Selector<DataFeedProvider, feed_ws.LiveProfit?>(
              selector: (_, provider) =>
                  provider.liveData[trade.symbol] ??
                  provider.liveData[(trade.symbol ?? "").toUpperCase()],
              builder: (context, liveData, _) {
                final currentLivePrice = isBuy
                    ? (liveData?.bid ?? entryPrice)
                    : (liveData?.ask ?? entryPrice);
                return _buildGridStat("Mark Price",
                    currentLivePrice.toStringAsFixed(2), textColor, greyText,
                    crossAlign: CrossAxisAlignment.end);
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
                child: _buildActionButton("TP/SL", greyText, dividerColor,
                    onTap: () => _showModifyBottomSheet(
                        context, trade, cardColor, textColor))),
            const SizedBox(width: 12),
            Expanded(
                child: _buildActionButton(
                    "Close Position", textColor, dividerColor,
                    bgColor: isDark ? Colors.white10 : Colors.grey.shade200,
                    onTap: () async {
              if (activeAccount.id != null) {
                await context
                    .read<TradeCubit>()
                    .closeTrade(trade.id, activeAccount.id!);
              }
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomPendingCard(
      BuildContext context,
      TradeModel trade,
      Account activeAccount,
      Color cardColor,
      Color textColor,
      Color greyText,
      Color dividerColor,
      bool isDark) {
    final isBuy = (trade.bs ?? 'Buy').toLowerCase() == 'buy';
    final sideColor = isBuy ? _binanceGreen : _binanceRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(isBuy ? "Limit Buy" : "Limit Sell",
                  style: TextStyle(
                      color: sideColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const SizedBox(width: 8),
              Text(trade.symbol ?? "Unknown",
                  style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              const Spacer(),
              Text(trade.openedAt?.split(' ').first ?? "",
                  style: TextStyle(color: greyText, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridStat(
                  "Amount", trade.lot.toString(), textColor, greyText),
              _buildGridStat("Order Price",
                  trade.avg?.toStringAsFixed(2) ?? "0.00", textColor, greyText,
                  crossAlign: CrossAxisAlignment.end),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton("Cancel Order", textColor, dividerColor,
                bgColor: isDark ? Colors.white10 : Colors.grey.shade200,
                onTap: () async {
              if (activeAccount.id != null) {
                await context
                    .read<TradeCubit>()
                    .closeTrade(trade.id, activeAccount.id!);
              }
            }),
          )
        ],
      ),
    );
  }

  Widget _buildCustomHistoryCard(TradeModel trade, Color cardColor,
      Color textColor, Color greyText, Color dividerColor, bool isDark) {
    final isBuy = (trade.bs ?? 'Buy').toLowerCase() == 'buy';
    final pnlVal = trade.profitLossAmount ?? 0.0;
    final pnlColor = pnlVal >= 0 ? _binanceGreen : _binanceRed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(isBuy ? "Buy" : "Sell",
                      style: TextStyle(
                          color: isBuy ? _binanceGreen : _binanceRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(trade.symbol ?? "Unknown",
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              Text(trade.openedAt?.split('.').first ?? "",
                  style: TextStyle(color: greyText, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGridStat(
                  "Filled", trade.lot.toString(), textColor, greyText),
              _buildGridStat("Entry Price",
                  trade.avg?.toStringAsFixed(2) ?? "0.00", textColor, greyText),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Realized PNL",
                      style: TextStyle(color: greyText, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text("${pnlVal >= 0 ? '+' : ''}${pnlVal.toStringAsFixed(2)}",
                      style: TextStyle(
                          color: pnlColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridStat(
      String label, String value, Color textColor, Color greyText,
      {CrossAxisAlignment crossAlign = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(label, style: TextStyle(color: greyText, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButton(String label, Color textColor, Color borderColor,
      {Color? bgColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: bgColor ?? Colors.transparent,
            border: Border.all(
                color: bgColor == null ? borderColor : Colors.transparent),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showModifyBottomSheet(BuildContext context, TradeModel trade,
      Color cardColor, Color textColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ModifyOrderSheet(
          avgPrice: trade.avg ?? 0.0,
          isBuy: (trade.bs ?? 'Buy').toLowerCase() == 'buy',
          currentSl: trade.sl,
          currentTp: trade.target,
          onConfirm: (double? newSl, double? newTp) {
            context.read<TradeCubit>().updateTrade(
                  tradeId: trade.id,
                  sl: newSl,
                  target: newTp,
                );
          },
        );
      },
    );
  }

  Widget _buildNoOrderUI(BuildContext context, String title, bool isDark,
      Color cardColor, Color greyText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
            child: Icon(CupertinoIcons.doc_text_search,
                size: 60, color: greyText.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: TextStyle(
                  color: greyText,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontSize: 16)),
          const SizedBox(height: 32),
          PremiumAppButton(
            text: 'Open a Trade',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) {
                  return const AccountSymbolSection();
                },
              );
            },
            width: MediaQuery.of(context).size.width * 0.5,
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ PULSATING DOT WIDGET
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final bool shouldPulse;

  const _AnimatedDot({
    required this.color,
    required this.shouldPulse,
  });

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(
              widget.shouldPulse ? _animation.value : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  widget.shouldPulse ? _animation.value * 0.5 : 0.3,
                ),
                blurRadius: widget.shouldPulse ? 6 : 3,
                spreadRadius: widget.shouldPulse ? 1 : 0,
              ),
            ],
          ),
        );
      },
    );
  }
}
