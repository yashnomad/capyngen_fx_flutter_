import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions.dart';
import '../../../cubit/symbol/symbol_state.dart';
import '../../../models/symbol_model.dart';
import '../../../provider/datafeed_provider.dart';
import '../../../services/data_feed_ws.dart';
import '../../../services/storage_service.dart';
import '../../../services/trading_view_service.dart';
import '../../../theme/app_colors.dart';
import '../../../services/switch_account_service.dart';
import '../../../theme/app_flavor_color.dart';
import '../../../utils/snack_bar.dart';
import '../../../widget/loader.dart';
import '../../../widget/slidepage_navigate.dart';
import '../btc_chart/btc_chart_screen_updated.dart';
import '../search/search_symbol_screen.dart';
import '../../../cubit/symbol/symbol_cubit.dart';
import 'new_trading_view.dart';

class AccountSymbolSection extends StatefulWidget {
  const AccountSymbolSection({super.key});

  @override
  State<AccountSymbolSection> createState() => _AccountSymbolSectionState();
}

class _AccountSymbolSectionState extends State<AccountSymbolSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TabController _tabController;
  final ValueNotifier<Set<int>> _expandedIndexesVN = ValueNotifier(<int>{});
  String? _lastUserId;

  final List<String> tabs = const [
    "Favorites",
    "All Symbols",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _expandedIndexesVN.dispose();
    super.dispose();
  }

  void _syncUserAccount(BuildContext context, String userId) {
    if (userId.isEmpty || _lastUserId == userId) return;

    _lastUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SymbolCubit>().getWatchList(userId);

      // Subscribe to existing favorites immediately if present
      final currentWatchlist = context.read<SymbolCubit>().state.watchlist;
      if (currentWatchlist.isNotEmpty) {
        final names = currentWatchlist
            .map((e) => e.symbolName.toUpperCase().trim())
            .toList();
        context.read<DataFeedProvider>().subscribeToSymbols(names);
      }

      final token = StorageService.getToken();
      if (token != null) {
        context.read<DataFeedProvider>().switchAccount(token, userId);
      }
    });
  }

  /// Returns a color based on the first letter of the symbol
  Color _getSymbolColor(String symbolName) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.green,
      Colors.deepPurple,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lime,
      Colors.brown,
    ];
    if (symbolName.isEmpty) return colors[0];
    final index = symbolName.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                    labelColor: context.tabLabelColor,
                    unselectedLabelColor: AppColor.greyColor,
                    indicatorColor: context.tabLabelColor,
                    indicatorWeight: 2,
                    tabs: tabs.map((e) => Tab(text: e)).toList(),
                  ),
                ),

                // Connection Status Indicator
                Consumer<DataFeedProvider>(
                  builder: (context, provider, _) {
                    final status = provider.socketStatus;
                    Color color;
                    String text;

                    switch (status) {
                      case SocketStatus.connected:
                        color = Colors.green;
                        text = "Live";
                        break;
                      case SocketStatus.connecting:
                        color = Colors.orange;
                        text = "Connecting...";
                        break;
                      case SocketStatus.disconnected:
                        color = Colors.red;
                        text = "Disconnected";
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                /// 🔍 SEARCH BUTTON
                SwitchAccountService(
                  accountBuilder: (context, account) {
                    return IconButton(
                      icon: const Icon(CupertinoIcons.search),
                      onPressed: () {
                        if (account.id == null || account.id!.isEmpty) {
                          SnackBarService.showError(
                              'Please select an account first');
                          return;
                        }
                        Navigator.push(
                          context,
                          SlidePageRoute(
                            page: SymbolSearchScreen(
                              userId: account.id!,
                              symbolCubit: context.read<SymbolCubit>(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  emptyChild: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 0, thickness: 0.5, color: AppColor.mediumGrey),
        SwitchAccountService(
          accountBuilder: (context, account) {
            final userId = account.id ?? '';
            _syncUserAccount(context, userId);

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFavoritesTab(userId),
                    _buildAllSymbolsTab(userId),
                  ],
                ),
              ),
            );
          },
          emptyChild: const Center(child: Text('No trading accounts')),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(String tradeUserId) {
    double clampPrice(double value) {
      if (value == 0) return 0;

      // max 5 decimals
      double rounded = double.parse(value.toStringAsFixed(5));

      // ensure min 2 decimals by normalizing again
      return double.parse(rounded.toStringAsFixed(
        rounded.truncateToDouble() == rounded ? 2 : 5,
      ));
    }

    return BlocListener<SymbolCubit, SymbolState>(
      listenWhen: (prev, curr) => prev.watchlist != curr.watchlist,
      listener: (context, state) {
        if (state.watchlist.isNotEmpty) {
          final names = state.watchlist
              .map((e) => e.symbolName)
              .map((n) => n.toUpperCase().trim())
              .toList();

          context.read<DataFeedProvider>().subscribeToSymbols(names);
        }
      },
      child: BlocBuilder<SymbolCubit, SymbolState>(
        builder: (context, state) {
          if (state.isWatchlistLoading && state.watchlist.isEmpty) {
            return const Loader();
          }

          if (state.watchlist.isEmpty) {
            return const Center(child: Text("No favorites added yet"));
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<SymbolCubit>().getWatchList(tradeUserId),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.watchlist.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1, color: AppFlavorColor.primary.withOpacity(0.15)),
              itemBuilder: (context, index) {
                final item = state.watchlist[index];
                final symbolName = item.symbolName.toUpperCase().trim();
                final firstLetter = symbolName.isNotEmpty ? symbolName[0] : '?';
                final symbolColor = _getSymbolColor(symbolName);

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context
                        .read<SymbolCubit>()
                        .removeFromWatchlist(item.id, tradeUserId);
                  },
                  child: Selector<DataFeedProvider, LiveProfit?>(
                    selector: (_, p) => p.liveData[symbolName],
                    builder: (_, live, __) {
                      final bid = clampPrice(live?.bid ?? 0.0);
                      final ask = clampPrice(live?.ask ?? 0.0);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => BTCChartScreenUpdated(
                                symbolName: symbolName,
                                id: item.symbolId,
                                tradeUserId: _lastUserId ?? '',
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // Coin circle with first letter
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: symbolColor.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: symbolColor.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstLetter,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: symbolColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Existing trading item
                              Expanded(
                                child: NewTradingItem(
                                  symbol: symbolName,
                                  bid: bid,
                                  ask: ask,
                                  isEven: index.isEven,
                                  low: bid != 0 ? bid * 0.99 : 0,
                                  high: ask != 0 ? ask * 1.01 : 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllSymbolsTab(String userId) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: BlocBuilder<SymbolCubit, SymbolState>(
        builder: (context, state) {
          if (state.isSymbolsLoading) {
            return const Loader();
          }
          return Scrollbar(
            child: ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: state.categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final String category = state.categories[index];
                final List<SymbolModel> symbols =
                    state.groupedSymbols[category]!;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: ValueListenableBuilder<Set<int>>(
                    valueListenable: _expandedIndexesVN,
                    builder: (_, expandedIndexes, __) {
                      final isExpanded = expandedIndexes.contains(index);
                      return _buildCategoryCard(
                          category, symbols, index, isExpanded, userId);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(String category, List<SymbolModel> symbols,
      int index, bool isExpanded, String userId) {
    return Container(
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: ValueKey('category_$index'),
            initiallyExpanded: isExpanded,
            onExpansionChanged: (expanded) {
              final set = {..._expandedIndexesVN.value};
              expanded ? set.add(index) : set.remove(index);
              _expandedIndexesVN.value = set;
            },
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isExpanded ? AppFlavorColor.primary : null,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppFlavorColor.primary.withOpacity(0.1)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: isExpanded ? AppFlavorColor.primary : Colors.grey,
                size: 20,
              ),
            ),
            children: [
              Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              ...symbols.map((symbol) => _buildSymbolListItem(symbol, userId)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolListItem(SymbolModel symbol, String userId) {
    return Container(
      color: context.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  symbol.symbolName[0],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade300),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol.symbolName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  Text("Market",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                context.read<SymbolCubit>().addToWatchlist(symbol.id, userId);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text("Add",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
