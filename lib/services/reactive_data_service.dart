// Your updated ReactiveDataService class

import 'package:exness_clone/services/data_feed_ws.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constant/symbol_calculation.dart';
import '../provider/datafeed_provider.dart';
// Import your new class
// import 'package:exness_clone/helpers/symbol_calculations.dart';

class ReactiveDataService extends StatelessWidget {
  final String symbolName;

  // The builder now provides BOTH the raw data AND the calculations
  final Widget Function(
      BuildContext context,
      LiveProfit liveData,
      SymbolCalculations calculations,
      ) builder;

  final Widget? loadingWidget;

  const ReactiveDataService({
    super.key,
    required this.symbolName,
    required this.builder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<DataFeedProvider, LiveProfit?>(
      selector: (_, provider) => provider.liveData[symbolName],
      builder: (context, liveData, _) {
        if (liveData == null) {
          return loadingWidget ??
              const Center(
                child: Text("0",)
                // child: Text("Waiting for live data..."),
              );
        }

        // 1. Create the calculations object from the live data
        final calculations = SymbolCalculations(liveData);

        // 2. Pass BOTH the raw data and the calculations to your builder
        return builder(context, liveData, calculations);
      },
    );
  }
}