/*
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/view/account/btc_chart/btc_chart_screen_updated.dart';
import 'package:exness_clone/view/account/chart_data/dummy_chart/dummy_chart_data.dart';
import 'package:exness_clone/view/account/widget/trading_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/symbol/symbol_cubit.dart';
import '../../services/switch_account_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/snack_bar.dart';
import '../../widget/slidepage_navigate.dart';
import '../account/account_screen.dart';
import '../account/search/search_symbol_screen.dart';


class SymbolBottomSheet extends StatefulWidget {
  const SymbolBottomSheet({super.key});

  @override
  State<SymbolBottomSheet> createState() => _SymbolBottomSheetState();
}

class _SymbolBottomSheetState extends State<SymbolBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    "Favorites",
    "All Symbols",
  ];

  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.internalDopDownColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              /// Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.mediumGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 TOP TAB BAR (YOUR PASTED WIDGET)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              tabs:
                              tabs.map((tab) => Tab(text: tab)).toList(),
                            ),
                          ),

                          /// 🔍 Search Button with account check
                          SwitchAccountService(
                            accountBuilder: (context, account) {
                              final accountId = account.id;

                              return IconButton(
                                icon:
                                const Icon(CupertinoIcons.search),
                                onPressed: () {
                                  if (accountId == null ||
                                      accountId.isEmpty) {
                                    SnackBarService.showError(
                                      'Please select an account first',
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    SlidePageRoute(
                                      page: SymbolSearchScreen(
                                        userId: accountId,
                                        symbolCubit:
                                        context.read<SymbolCubit>(),
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
                  Divider(
                    height: 0,
                    thickness: 0.5,
                    color: AppColor.mediumGrey,
                  ),
                ],
              ),

              /// 🔹 TAB CONTENT (YOUR PASTED WIDGET)
              Expanded(
                child: SwitchAccountService(
                  accountBuilder: (context, account) {
                    return WatchlistFetcher(
                      userId: account.id ?? '',
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            FavoritesTab(
                              tradeUserId: account.id ?? '',
                            ),
                            AllSymbolsTab(
                              userId: account.id ?? '',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  emptyChild: const Center(
                    child: Text('No trading accounts'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
*/
