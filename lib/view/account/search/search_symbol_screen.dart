import 'package:exness_clone/widget/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Ensure these imports match your project structure
import '../../../cubit/symbol/symbol_cubit.dart';
import '../../../cubit/symbol/symbol_state.dart';
import '../../../models/symbol_model.dart';
import 'package:exness_clone/core/extensions.dart'; // Keep your extensions

class SymbolSearchScreen extends StatefulWidget {
  final String userId;
  final SymbolCubit symbolCubit; // 1. Add this to accept existing data

  const SymbolSearchScreen({
    super.key,
    required this.userId,
    required this.symbolCubit,
  });

  @override
  State<SymbolSearchScreen> createState() => _SymbolSearchScreenState();
}

class _SymbolSearchScreenState extends State<SymbolSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Map<String, List<SymbolModel>> _getFilteredSymbols(
      Map<String, List<SymbolModel>> groupedSymbols, List<String> categories) {
    // If search is empty, return empty (UI handles the "Start searching" view)
    if (_searchQuery.isEmpty) return {};

    final Map<String, List<SymbolModel>> filtered = {};

    for (var category in categories) {
      final symbols = groupedSymbols[category] ?? [];

      final matchingSymbols = symbols.where((symbol) {
        return symbol.symbolName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();

      if (matchingSymbols.isNotEmpty) {
        filtered[category] = matchingSymbols;
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.symbolCubit,
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: "Search symbols...",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          actions: [
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = "";
                  });
                },
              ),
          ],
        ),
        body: BlocBuilder<SymbolCubit, SymbolState>(
          builder: (context, state) {
            // If the original screen was still loading, show loader here too
            if (state.isSymbolsLoading) {
              return Loader();
            }

            if (_searchQuery.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey.shade200),
                    const SizedBox(height: 16),
                    Text(
                      "Search for markets",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            // 2. Filter the data
            final filteredGrouped =
                _getFilteredSymbols(state.groupedSymbols, state.categories);
            final filteredCategories = filteredGrouped.keys.toList();

            // 3. User typed, but no matches found
            if (filteredCategories.isEmpty) {
              return Center(
                child: Text(
                  "No symbols found",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(10),
              itemCount: filteredCategories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final String category = filteredCategories[index];
                final List<SymbolModel> symbols = filteredGrouped[category]!;

                return _buildCategoryCard(
                  context,
                  category,
                  symbols,
                  index,
                  true,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category,
      List<SymbolModel> symbols, int index, bool isExpanded) {
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
            key: ValueKey('search_cat_$category'),
            initiallyExpanded: isExpanded,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            title: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            children: [
              Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              ...symbols.map((symbol) => _buildSymbolItem(symbol)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolItem(SymbolModel symbol) {
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
                  symbol.symbolName.isNotEmpty ? symbol.symbolName[0] : "?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol.symbolName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    "Market",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                widget.symbolCubit.addToWatchlist(symbol.id, widget.userId);
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
                    Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
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
