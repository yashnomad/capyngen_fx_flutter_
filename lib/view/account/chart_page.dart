import 'package:exness_clone/view/account/buy_sell_trade/cubit/trade_cubit.dart';
import 'package:exness_clone/view/account/buy_sell_trade/cubit/trade_state.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_payload.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/services/trading_view_service.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/provider/datafeed_provider.dart';
import 'package:exness_clone/services/data_feed_ws.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/snack_bar.dart';

import '../../cubit/symbol/symbol_cubit.dart';
import '../../cubit/symbol/symbol_state.dart';
import '../../models/symbol_model.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  WebViewController? _controller;
  final TradingViewService _chartService = TradingViewService();

  String _selectedSymbol = "BTCUSD";
  String _selectedInterval = "60";
  String? _lastLoadedUserId;

  final TextEditingController _lotController =
      TextEditingController(text: "0.01");
  double _lotSize = 0.01;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SymbolCubit>().getAllSymbols();
      _subscribeToSymbol(_selectedSymbol);
    });
  }

  @override
  void dispose() {
    _lotController.dispose();
    super.dispose();
  }

  void _subscribeToSymbol(String symbol) {
    if (symbol.isEmpty) return;
    context.read<DataFeedProvider>().subscribeToSymbols([symbol.toUpperCase()]);
  }

  void _loadChart(String symbol, String interval, String tradeUserId) {
    if (!mounted) return;
    _subscribeToSymbol(symbol);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _lastLoadedUserId = tradeUserId;
          _controller = _chartService.getController(
            symbol,
            interval: interval,
            tradeUserId: tradeUserId,
            context: context,
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
          );
        });
      }
    });
  }

  void _incrementLot() {
    setState(() {
      _lotSize = double.parse((_lotSize + 0.01).toStringAsFixed(2));
      _lotController.text = _lotSize.toString();
    });
  }

  void _decrementLot() {
    if (_lotSize > 0.01) {
      setState(() {
        _lotSize = double.parse((_lotSize - 0.01).toStringAsFixed(2));
        _lotController.text = _lotSize.toString();
      });
    }
  }

  void _onTrade(bool isBuy, String accountId) {
    final token = StorageService.getToken();
    if (token == null) {
      SnackBarService.showError("Authentication Error. Please Login.");
      return;
    }

    final symbolState = context.read<SymbolCubit>().state;
    String? symbolId;

    outerLoop:
    for (var key in symbolState.groupedSymbols.keys) {
      final list = symbolState.groupedSymbols[key] ?? [];
      for (var sym in list) {
        if (sym.symbolName == _selectedSymbol) {
          symbolId = sym.id;
          break outerLoop;
        }
      }
    }

    if (symbolId == null) {
      SnackBarService.showError(
          "Symbol Data not found. Please wait or refresh.");
      return;
    }

    final provider = context.read<DataFeedProvider>();
    final liveData = provider.liveData[_selectedSymbol] ??
        provider.liveData[_selectedSymbol.toUpperCase()];

    double currentPrice = 0.0;

    if (liveData != null && (isBuy ? liveData.ask : liveData.bid) > 0) {
      currentPrice = isBuy ? liveData.ask : liveData.bid;
    }

    if (currentPrice == 0.0) {
      SnackBarService.showError(
          "Waiting for price update... (Try tapping again)");
      _subscribeToSymbol(_selectedSymbol);
      return;
    }

    final payload = TradePayload(
      symbol: symbolId!,
      lot: _lotSize,
      bs: isBuy ? 'Buy' : 'Sell',
      tradeAccountId: accountId,
      executionType: 'market',
      avg: currentPrice,
    );

    context.read<TradeCubit>().createTrade(
          payload: payload,
          jwt: token,
        );
  }

  void _showSymbolSelector(String currentId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String searchQuery = "";

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      "Select Symbol",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.tabLabelColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        style: TextStyle(color: context.tabLabelColor),
                        decoration: InputDecoration(
                          hintText: "Search Coin (e.g. BTC)",
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          filled: true,
                          fillColor: context.boxDecorationColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    Expanded(
                      child: BlocBuilder<SymbolCubit, SymbolState>(
                        builder: (context, state) {
                          if (state.isSymbolsLoading) {
                            return Center(
                                child: CircularProgressIndicator(
                                    color: AppFlavorColor.primary));
                          }
                          List<SymbolModel> allSymbols = [];
                          state.groupedSymbols.forEach((key, value) {
                            allSymbols.addAll(value);
                          });
                          List<SymbolModel> filteredSymbols =
                              allSymbols.where((s) {
                            return s.symbolName
                                .toLowerCase()
                                .contains(searchQuery);
                          }).toList();
                          if (filteredSymbols.isEmpty) {
                            return const Center(
                              child: Text("No symbols found",
                                  style: TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.separated(
                            controller: controller,
                            itemCount: filteredSymbols.length,
                            separatorBuilder: (_, __) => Divider(
                              color: Colors.grey.withOpacity(0.1),
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final symbol = filteredSymbols[index];
                              final isSelected =
                                  symbol.symbolName == _selectedSymbol;
                              return ListTile(
                                title: Text(
                                  symbol.symbolName,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? AppFlavorColor.primary
                                        : context.tabLabelColor,
                                  ),
                                ),
                                subtitle: Text(
                                  "Market",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check,
                                        color: AppFlavorColor.primary)
                                    : null,
                                onTap: () {
                                  _subscribeToSymbol(symbol.symbolName);
                                  setState(() {
                                    _selectedSymbol = symbol.symbolName;
                                    _loadChart(_selectedSymbol,
                                        _selectedInterval, currentId);
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SwitchAccountService(
      accountBuilder: (context, account) {
        final tradeUserId = account.id ?? '';

        if (tradeUserId.isNotEmpty &&
            (_controller == null || _lastLoadedUserId != tradeUserId)) {
          Future.delayed(Duration.zero, () {
            if (mounted)
              _loadChart(_selectedSymbol, _selectedInterval, tradeUserId);
          });
        }

        return BlocListener<TradeCubit, TradeState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              SnackBarService.showSuccess(state.successMessage!);
            }
            if (state.errorMessage != null) {
              SnackBarService.showError(state.errorMessage!);
            }
          },
          child: Scaffold(
            backgroundColor: context.backgroundColor,
            appBar: AppBar(
              title: const Text(
                'Chart',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              actions: [
                GestureDetector(
                  onTap: () => tradeUserId.isNotEmpty
                      ? _showSymbolSelector(tradeUserId)
                      : null,
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.boxDecorationColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedSymbol,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.tabLabelColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: context.tabLabelColor,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildTradeBottomBar(tradeUserId),
            body: Column(
              children: [
                Expanded(
                  child: _controller == null
                      ? Center(
                          child: CircularProgressIndicator(
                              color: AppFlavorColor.primary))
                      : Selector<DataFeedProvider, LiveProfit?>(
                          selector: (_, provider) {
                            return provider.liveData[_selectedSymbol] ??
                                provider
                                    .liveData[_selectedSymbol.toUpperCase()];
                          },
                          shouldRebuild: (prev, next) =>
                              prev?.timestamp != next?.timestamp,
                          builder: (context, liveProfit, _) {
                            if (liveProfit != null) {
                              _chartService.updateLiveData(
                                symbol: _selectedSymbol,
                                bid: liveProfit.bid,
                                ask: liveProfit.ask,
                                timestamp: liveProfit.timestamp,
                              );
                            }
                            return WebViewWidget(controller: _controller!);
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
      emptyChild: Scaffold(
        backgroundColor: context.backgroundColor,
        body: Center(
          child: Text(
            "Please select a trading account",
            style: TextStyle(color: context.tabLabelColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeBottomBar(String accountId) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: BlocBuilder<TradeCubit, TradeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blueColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: state.isLoading
                        ? null
                        : () => _onTrade(true, accountId),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("BUY",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                  color: context.boxDecorationColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _stepperButton(Icons.remove, _decrementLot),
                    Expanded(
                      child: TextField(
                        controller: _lotController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          final newVal = double.tryParse(val);
                          if (newVal != null) {
                            _lotSize = newVal;
                          }
                        },
                      ),
                    ),
                    _stepperButton(Icons.add, _incrementLot),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: BlocBuilder<TradeCubit, TradeState>(
                builder: (context, state) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.redColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: state.isLoading
                        ? null
                        : () => _onTrade(false, accountId),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text("SELL",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 40,
        height: double.infinity,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: Colors.grey),
      ),
    );
  }
}
