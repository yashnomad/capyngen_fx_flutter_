import 'dart:io';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/buy_sell_trade/demo_screen.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:exness_clone/view/account/trade_screen/widget/history_summary_card.dart';
import 'package:exness_clone/view/account/trade_screen/widget/modify_trade.dart';
import 'package:exness_clone/view/account/trade_screen/widget/order_prgress_card.dart';
import 'package:exness_clone/view/trade/widget/account_summary_card.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/switch_account_service.dart';
import '../../../services/trade_pdf_service.dart';
import '../../../theme/app_colors.dart';
import '../../trade/widget/unified_summary_card.dart';
import '../buy_sell_trade/cubit/trade_cubit.dart';
import '../buy_sell_trade/cubit/trade_state.dart';
import '../buy_sell_trade/model/trade_model.dart';
import '../widget/account_symbol_section.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabIndex = 3;
  String? _lastFetchedAccountId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabIndex, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SwitchAccountService(
          accountBuilder: (context, activeAccount) {
            if (activeAccount.id != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchDataForAccount(activeAccount.id!);
              });
            }

            return DefaultTabController(
              length: _tabIndex,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  flexibleSpace: Container(color: context.backgroundColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trade',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Account: ${activeAccount.accountId}",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    if (activeAccount.id != null) {
                      _fetchDataForAccount(activeAccount.id!,
                          forceRefresh: true);
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                  },
                  child: BlocListener<TradeCubit, TradeState>(
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
                    child: NestedScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverToBoxAdapter(
                          child: BlocBuilder<TradeCubit, TradeState>(
                            builder: (context, state) {
                              // if (state.equity != null) {
                              return UnifiedSummaryCard(
                                selectedIndex: _tabController.index,
                                state: state,
                                onDownloadPdf: () async {
                                  if (activeAccount.id != null) {
                                    await _downloadPdf(context,
                                        state.historyTrades, activeAccount.id!);
                                  }
                                },
                              );
                              // }
                              // return const SizedBox.shrink();
                            },
                          ),
                        ),
                        SliverAppBar(
                          toolbarHeight: 50,
                          pinned: true,
                          titleSpacing: 0,
                          flexibleSpace: Container(
                            color: context.backgroundColor,
                          ),
                          title: TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            tabAlignment: TabAlignment.start,
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.w500),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.grey.shade100,
                            unselectedLabelColor: AppColor.greyColor,
                            labelColor: context.tabLabelColor,
                            indicatorColor: context.tabLabelColor,
                            tabs: const [
                              Tab(text: "Current Positions"),
                              Tab(text: "Pending Positions"),
                              Tab(text: "Order History"),
                            ],
                          ),
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          BlocBuilder<TradeCubit, TradeState>(
                            buildWhen: (previous, current) =>
                                previous.activeTrades != current.activeTrades ||
                                previous.equity != current.equity,
                            builder: (context, state) {
                              final hasActiveTrades =
                                  state.activeTrades.isNotEmpty;

                              if (!hasActiveTrades) {
                                return _buildNoOrderUI(context, 'No Positions');
                              }

                              return Column(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(top: 16),
                                      itemCount: state.activeTrades.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final trade = state.activeTrades[index];
                                        final liveProfit =
                                            state.equity?.liveProfit.firstWhere(
                                                  (element) =>
                                                      element.id == trade.id,
                                                  orElse: () => LiveProfit(
                                                    id: trade.id,
                                                    profit: trade
                                                            .profitLossAmount ??
                                                        0.0,
                                                    avg: trade.avg,
                                                    price: null,
                                                  ),
                                                ) ??
                                                LiveProfit(
                                                    id: trade.id, profit: 0.0);

                                        return OrderProgressCard(
                                          trade: trade,
                                          liveProfit: liveProfit,
                                          isHistory: false,
                                          onModify: () async {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16)),
                                              ),
                                              builder: (context) {
                                                return ModifyOrderSheet(
                                                  avgPrice: trade.avg ?? 0.0,
                                                  isBuy: (trade.bs ?? 'Buy')
                                                          .toLowerCase() ==
                                                      'buy',
                                                  currentSl: trade.sl,
                                                  currentTp: trade.target,
                                                  onConfirm: (double? newSl,
                                                      double? newTp) {
                                                    context
                                                        .read<TradeCubit>()
                                                        .updateTrade(
                                                          tradeId: trade.id,
                                                          sl: newSl,
                                                          target: newTp,
                                                        );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          onDelete: () async {
                                            if (activeAccount.id != null) {
                                              await context
                                                  .read<TradeCubit>()
                                                  .closeTrade(trade.id,
                                                      activeAccount.id!);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      border: Border(
                                          top: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 0.5)),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildSummaryItem("Balance",
                                              state.equity?.balance ?? "0.00"),
                                          _buildSummaryItem("Equity",
                                              state.equity?.equity ?? "0.00"),
                                          _buildSummaryItem(
                                              "Used Mrg",
                                              state.equity?.usedMargin ??
                                                  "0.00"),
                                          _buildSummaryItem(
                                              "Free Mrg",
                                              state.equity?.freeMargin ??
                                                  "0.00"),
                                          _buildSummaryItem(
                                            "Total P/L",
                                            state.equity?.pnl ?? "0.00",
                                            isPnL: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          BlocBuilder<TradeCubit, TradeState>(
                              buildWhen: (previous, current) =>
                                  previous.pendingTrades !=
                                  current.pendingTrades,
                              builder: (context, state) {
                                if (state.pendingTrades.isEmpty) {
                                  return _buildNoOrderUI(
                                      context, 'No Pending Orders');
                                }

                                return Column(
                                  children: [
                                    Expanded(
                                      child: ListView.separated(
                                        // padding: const EdgeInsets.only(top: 8),
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: const EdgeInsets.only(top: 16),
                                        itemCount: state.pendingTrades.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final trade =
                                              state.pendingTrades[index];
                                          return OrderProgressCard(
                                            trade: trade,
                                            liveProfit: LiveProfit(
                                                id: trade.id, profit: 0),
                                            isHistory: false,
                                            onDelete: () async {
                                              if (activeAccount.id != null) {
                                                await context
                                                    .read<TradeCubit>()
                                                    .closeTrade(trade.id,
                                                        activeAccount.id!);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          BlocBuilder<TradeCubit, TradeState>(
                            buildWhen: (previous, current) =>
                                previous.historyTrades != current.historyTrades,
                            builder: (context, state) {
                              final hasHistoryTrades =
                                  state.historyTrades.isNotEmpty;
                              return hasHistoryTrades
                                  ? ListView.separated(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(top: 16),
                                      itemCount: state.historyTrades.length + 1,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        // if (index == 0) {
                                        //   return HistorySummaryCard(
                                        //     trades: state.historyTrades,
                                        //     onDownload: () async {
                                        //       if (activeAccount.id != null) {
                                        //         await _downloadPdf(
                                        //           context,
                                        //           state.historyTrades,
                                        //           activeAccount.id!,
                                        //         );
                                        //       }
                                        //     },
                                        //   );
                                        // }
                                        final trade =
                                            state.historyTrades[index];
                                        // state.historyTrades[index - 1];
                                        final liveProfit = LiveProfit(
                                          id: trade.id,
                                          profit: trade.profitLossAmount ?? 0.0,
                                        );

                                        return OrderProgressCard(
                                          trade: trade,
                                          liveProfit: liveProfit,
                                          isHistory: true,
                                          onDelete: () async {},
                                        );
                                      },
                                    )
                                  : _buildNoOrderUI(
                                      context, 'No Order History');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoOrderUI(BuildContext context, String orderType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/no_order.png', height: 70),
          Text(orderType,
              style: TextStyle(
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(height: 15),
          PremiumAppButton(
            text: 'New Order',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return const AccountSymbolSection();
                },
              );
            },
            width: MediaQuery.of(context).size.width * 0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isPnL = false}) {
    double val = double.tryParse(value) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  isPnL ? (val >= 0 ? Colors.green : Colors.red) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'dart:io';

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/ws_equity_data.dart';
import 'package:exness_clone/view/account/trade_screen/widget/history_summary_card.dart';
import 'package:exness_clone/view/account/trade_screen/widget/modify_trade.dart';
import 'package:exness_clone/view/account/trade_screen/widget/order_prgress_card.dart';
import 'package:exness_clone/view/trade/widget/account_summary_card.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/switch_account_service.dart';
import '../../../services/trade_pdf_service.dart';
import '../../../theme/app_colors.dart';
import '../buy_sell_trade/cubit/trade_cubit.dart';
import '../buy_sell_trade/cubit/trade_state.dart';
import '../buy_sell_trade/model/trade_model.dart';
import '../widget/account_symbol_section.dart';

class TradeScreen extends StatefulWidget {
  const TradeScreen({super.key});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final int _tabIndex = 3;
  String? _lastFetchedAccountId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabIndex, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SwitchAccountService(
          accountBuilder: (context, activeAccount) {
            if (activeAccount.id != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchDataForAccount(activeAccount.id!);
              });
            }

            return DefaultTabController(
              length: _tabIndex,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  flexibleSpace: Container(color: context.backgroundColor),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trade',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Account: ${activeAccount.accountId}",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    if (activeAccount.id != null) {
                      _fetchDataForAccount(activeAccount.id!,
                          forceRefresh: true);
                      await Future.delayed(const Duration(milliseconds: 500));
                    }
                  },
                  child: BlocListener<TradeCubit, TradeState>(
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
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) => [
                        SliverToBoxAdapter(
                          child: BlocBuilder<TradeCubit, TradeState>(
                            buildWhen: (previous, current) =>
                                previous.equity != current.equity,
                            builder: (context, state) {
                              if (state.equity != null) {
                                return AccountSummaryCard(
                                  balance: state.equity!.balance ?? '',
                                  equity: state.equity!.equity,
                                  margin: state.equity!.usedMargin ?? '',
                                  freeMargin: state.equity!.freeMargin ?? '',
                                  floatingPnL: state.equity!.pnl,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        SliverAppBar(
                          toolbarHeight: 50,
                          pinned: true,
                          titleSpacing: 0,
                          flexibleSpace: Container(
                            color: context.backgroundColor,
                          ),
                          title: TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            tabAlignment: TabAlignment.start,
                            labelStyle:
                                const TextStyle(fontWeight: FontWeight.w500),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.grey.shade100,
                            unselectedLabelColor: AppColor.greyColor,
                            labelColor: context.tabLabelColor,
                            indicatorColor: context.tabLabelColor,
                            tabs: const [
                              Tab(text: "Current Positions"),
                              Tab(text: "Pending Positions"),
                              Tab(text: "Order History"),
                            ],
                          ),
                        ),
                      ],
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          BlocBuilder<TradeCubit, TradeState>(
                            buildWhen: (previous, current) =>
                                previous.activeTrades != current.activeTrades ||
                                previous.equity != current.equity,
                            builder: (context, state) {
                              final hasActiveTrades =
                                  state.activeTrades.isNotEmpty;

                              if (!hasActiveTrades) {
                                return _buildNoOrderUI(context, 'No Positions');
                              }

                              return Column(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      // padding: const EdgeInsets.all(12),
                                      itemCount: state.activeTrades.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final trade = state.activeTrades[index];
                                        final liveProfit =
                                            state.equity?.liveProfit.firstWhere(
                                                  (element) =>
                                                      element.id == trade.id,
                                                  orElse: () => LiveProfit(
                                                    id: trade.id,
                                                    profit: trade
                                                            .profitLossAmount ??
                                                        0.0,
                                                    avg: trade.avg,
                                                    price: null,
                                                  ),
                                                ) ??
                                                LiveProfit(
                                                    id: trade.id, profit: 0.0);

                                        return OrderProgressCard(
                                          trade: trade,
                                          liveProfit: liveProfit,
                                          isHistory: false,
                                          onModify: () async {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            16)),
                                              ),
                                              builder: (context) {
                                                return ModifyOrderSheet(
                                                  avgPrice: trade.avg ?? 0.0,
                                                  isBuy: (trade.bs ?? 'Buy')
                                                          .toLowerCase() ==
                                                      'buy',
                                                  currentSl: trade.sl,
                                                  currentTp: trade.target,
                                                  onConfirm: (double? newSl,
                                                      double? newTp) {
                                                    context
                                                        .read<TradeCubit>()
                                                        .updateTrade(
                                                          tradeId: trade.id,
                                                          sl: newSl,
                                                          target: newTp,
                                                        );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          onDelete: () async {
                                            if (activeAccount.id != null) {
                                              await context
                                                  .read<TradeCubit>()
                                                  .closeTrade(trade.id,
                                                      activeAccount.id!);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: context.backgroundColor,
                                      border: Border(
                                          top: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 0.5)),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildSummaryItem("Balance",
                                              state.equity?.balance ?? "0.00"),
                                          _buildSummaryItem("Equity",
                                              state.equity?.equity ?? "0.00"),
                                          _buildSummaryItem(
                                              "Used Mrg",
                                              state.equity?.usedMargin ??
                                                  "0.00"),
                                          _buildSummaryItem(
                                              "Free Mrg",
                                              state.equity?.freeMargin ??
                                                  "0.00"),
                                          _buildSummaryItem(
                                            "Total P/L",
                                            state.equity?.pnl ?? "0.00",
                                            isPnL: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          BlocBuilder<TradeCubit, TradeState>(
                              buildWhen: (previous, current) =>
                                  previous.pendingTrades !=
                                  current.pendingTrades,
                              builder: (context, state) {
                                if (state.pendingTrades.isEmpty) {
                                  return _buildNoOrderUI(
                                      context, 'No Pending Orders');
                                }

                                return Column(
                                  children: [
                                    Expanded(
                                      child: ListView.separated(
                                        // padding: const EdgeInsets.all(12),
                                        itemCount: state.pendingTrades.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final trade =
                                              state.pendingTrades[index];
                                          return OrderProgressCard(
                                            trade: trade,
                                            liveProfit: LiveProfit(
                                                id: trade.id, profit: 0),
                                            isHistory: false,
                                            onDelete: () async {
                                              if (activeAccount.id != null) {
                                                await context
                                                    .read<TradeCubit>()
                                                    .closeTrade(trade.id,
                                                        activeAccount.id!);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    if (state.pendingTrades.isNotEmpty)
                                      _buildTotalSection("Total Pending",
                                          state.pendingTrades.length.toString(),
                                          isPrice: false),
                                  ],
                                );
                              }),
                          BlocBuilder<TradeCubit, TradeState>(
                            buildWhen: (previous, current) =>
                                previous.historyTrades != current.historyTrades,
                            builder: (context, state) {
                              final hasHistoryTrades =
                                  state.historyTrades.isNotEmpty;
                              return hasHistoryTrades
                                  ? ListView.separated(
                                      // padding: const EdgeInsets.all(12),
                                      itemCount: state.historyTrades.length + 1,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return HistorySummaryCard(
                                            trades: state.historyTrades,
                                            onDownload: () async {
                                              if (activeAccount.id != null) {
                                                await _downloadPdf(
                                                  context,
                                                  state.historyTrades,
                                                  activeAccount.id!,
                                                );
                                              }
                                            },
                                          );
                                        }
                                        final trade =
                                            state.historyTrades[index - 1];
                                        final liveProfit = LiveProfit(
                                          id: trade.id,
                                          profit: trade.profitLossAmount ?? 0.0,
                                        );

                                        return OrderProgressCard(
                                          trade: trade,
                                          liveProfit: liveProfit,
                                          isHistory: true,
                                          onDelete: () async {},
                                        );
                                      },
                                    )
                                  : _buildNoOrderUI(
                                      context, 'No Order History');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoOrderUI(BuildContext context, String orderType) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/image/no_order.png', height: 70),
          Text(orderType,
              style: TextStyle(
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(height: 15),
          PremiumAppButton(
            text: 'New Order',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return const AccountSymbolSection();
                },
              );
            },
            width: MediaQuery.of(context).size.width * 0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(String label, String value, {bool isPrice = true}) {
    final double val = double.tryParse(value) ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrice
                  ? (val >= 0 ? Colors.green : Colors.red)
                  : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isPnL = false}) {
    double val = double.tryParse(value) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  isPnL ? (val >= 0 ? Colors.green : Colors.red) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}*/
