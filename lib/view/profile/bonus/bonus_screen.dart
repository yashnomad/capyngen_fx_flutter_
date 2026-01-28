import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:flutter/material.dart';

class BonusScreen extends StatefulWidget {
  const BonusScreen({super.key});

  @override
  State<BonusScreen> createState() => _BonusScreenState();
}

class _BonusScreenState extends State<BonusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool hideUnavailable = false;
  int selectedFilterIndex = 0;

  int selectedTabIndex = 0;
  final List<String> bonusFilters = [
    'All',
    'Active',
    'Pending',
    'Completed',
    'Expired',
    'Error'
  ];
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _chipKeys;

  void scrollToChipIfNeeded(int index) {
    final keyContext = _chipKeys[index].currentContext;
    if (keyContext == null) return;

    final box = keyContext.findRenderObject() as RenderBox;
    final position =
        box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());

    double screenWidth = MediaQuery.of(context).size.width;

    // Animate scroll to center the selected chip
    double targetScrollOffset = _scrollController.offset +
        position.dx -
        screenWidth / 2 +
        box.size.width / 2;

    _scrollController.animateTo(
      targetScrollOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _chipKeys = List.generate(bonusFilters.length, (index) => GlobalKey());
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text("Bonuses",
            style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColor.mediumGrey),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColor.greenColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: context.tabLabelColor,
                unselectedLabelColor: AppColor.greyColor,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: context.tabLabelColor,
                dividerColor: AppColor.transparent,
                splashBorderRadius: BorderRadius.circular(30),
                tabs: const [
                  Tab(text: 'Available Programs'),
                  Tab(text: 'My Bonuses'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _availableProgramsTab(),
          _myBonusesTab(),
        ],
      ),
    );
  }

  Widget _availableProgramsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                value: hideUnavailable,
                onChanged: (val) {
                  setState(() => hideUnavailable = val!);
                },
                side: BorderSide(
                  width: 1.0, // 👈 Adjust this for thinner or thicker border
                  color: AppColor.greyColor,
                ),
              ),
              const Text('Hide unavailable programs'),
            ],
          ),
          const SizedBox(height: 60),
          _emptyState(
            icon: Icons.card_giftcard,
            title: "No available programs found",
            subtitle: "Check back later for new bonus programs",
          ),
        ],
      ),
    );
  }

  Widget _myBonusesTab() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: bonusFilters.length,
              itemBuilder: (context, index) {
                bool isSelected = selectedTabIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = index;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToChipIfNeeded(index);
                      });
                    },
                    child: AnimatedContainer(
                      key: _chipKeys[index],
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.greenColor
                            : AppColor.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.transparent
                              : AppColor.lightGrey,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          bonusFilters[index],
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? AppColor.whiteColor
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColor.greyColor
                                    : AppColor.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 60),
        _emptyState(
          icon: Icons.card_giftcard,
          title: "No bonuses found",
          subtitle: "Claim some bonuses to see them here",
        ),
      ],
    );
  }

  Widget _emptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white10
              : Colors.black87,
          child: Icon(icon, size: 32, color: AppColor.whiteColor),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColor.greyColor),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(color: AppColor.greyColor),
        ),
      ],
    );
  }
}
