import 'package:exness_clone/view/account/btc_chart/new_btc_chart_screen.dart';
import 'package:exness_clone/view/account/chart_data/finnhub/stock_data.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../widget/shimmer/trading_item_shimmer.dart';
import '../../widget/trading_item.dart';
import 'finnhub_service.dart';

class LiveStocksScreen extends StatefulWidget {
  const LiveStocksScreen({super.key});

  @override
  State<LiveStocksScreen> createState() => _LiveStocksScreenState();
}

class _LiveStocksScreenState extends State<LiveStocksScreen> {
  final FinnhubService _finnhubService = FinnhubService();
  final Map<String, StockData> _stocks = {};
  late StreamSubscription<StockData> _stockSubscription;
  bool _isLoading = true;

  final List<String> _watchedSymbols = [
    'AAPL',
    'GOOGL',
    'MSFT',
    'TSLA',
    'AMZN',
    'NVDA',
    'META',
    'NFLX',
    'BTC',
    'ETH',
  ];

  @override
  void initState() {
    super.initState();
    _initializeStockData();
  }

  Future<void> _initializeStockData() async {
    await _finnhubService.connectWebSocket();

    _stockSubscription = _finnhubService.stockStream.listen((stockData) {
      if (mounted) {
        setState(() {
          _stocks[stockData.symbol] = stockData;
        });
      }
    });

    for (String symbol in _watchedSymbols) {
      if (!symbol.contains(':')) {
        final stockData = await _finnhubService.getStockQuote(symbol);
        if (stockData != null && mounted) {
          setState(() {
            _stocks[symbol] = stockData;
          });
        }
      }
      _finnhubService.subscribeToSymbol(symbol);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getIconForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return Icons.apple;
      case 'GOOGL':
        return Icons.language;
      case 'MSFT':
        return Icons.computer;
      case 'TSLA':
        return Icons.electric_car;
      case 'AMZN':
        return Icons.shopping_cart;
      case 'NVDA':
        return Icons.memory;
      case 'META':
        return Icons.facebook;
      case 'NFLX':
        return Icons.movie;
      case 'BTC':
        return Icons.currency_bitcoin;
      case 'ETH':
        return Icons.diamond;
      default:
        return Icons.trending_up;
    }
  }

  String _getDisplayName(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'AAPL':
        return 'Apple Inc.';
      case 'GOOGL':
        return 'Alphabet Inc.';
      case 'MSFT':
        return 'Microsoft Corp.';
      case 'TSLA':
        return 'Tesla Inc.';
      case 'AMZN':
        return 'Amazon.com Inc.';
      case 'NVDA':
        return 'NVIDIA Corp.';
      case 'META':
        return 'Meta Platforms';
      case 'NFLX':
        return 'Netflix Inc.';
      case 'BTC':
        return 'Bitcoin';
      case 'ETH':
        return 'Ethereum';
      default:
        return symbol;
    }
  }

  Color _getChartColor(double change) {
    return change >= 0 ? Colors.green : Colors.red;
  }

  @override
  void dispose() {
    _stockSubscription.cancel();
    _finnhubService.dispose();
    super.dispose();
  }

  Future<void> _refreshStocks() async {
    setState(() {
      _isLoading = true;
      _stocks.clear();
    });

    await _initializeStockData();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, __) => const TradingItemShimmer(),
          )
        : RefreshIndicator(
            onRefresh: _refreshStocks,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _watchedSymbols.length,
              // separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final symbol = _watchedSymbols[index];
                final stockData = _stocks[symbol];

                if (stockData == null) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Icon(_getIconForSymbol(symbol)),
                    ),
                    title: Text(_getDisplayName(symbol)),
                    subtitle: Text(symbol),
                  );
                }

                final changeText = '${stockData.change >= 0 ? '↑' : '↓'} '
                    '\$${stockData.change.abs().toStringAsFixed(2)} '
                    '(${stockData.changePercent.toStringAsFixed(2)}%)';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewBTCChartScreen(
                          symbol: symbol,
                          displayName: _getDisplayName(symbol),
                          currentPrice: stockData.price,
                          change: stockData.change,
                          changePercent: stockData.changePercent,
                          icon: _getIconForSymbol(symbol),
                          chartData: stockData.chartData,
                        ),
                      ),
                    );
                  },
                  child: TradingItem(
                    // title: _getDisplayName(symbol),
                    // subtitle: symbol,
                    subtitle: _getDisplayName(symbol),
                    title: symbol,

                    price: stockData.price,
                    change: changeText,
                    chartColor: _getChartColor(stockData.change),
                    flag: '🇺🇸',
                    icon: _getIconForSymbol(symbol),
                    chartData: stockData.chartData.isNotEmpty
                        ? stockData.chartData
                        : [stockData.price],
                  ),
                );
              },
            ),
          );
  }
}
