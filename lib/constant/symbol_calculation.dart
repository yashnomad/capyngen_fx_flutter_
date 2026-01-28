import 'dart:math';

import '../services/data_feed_ws.dart'; // For 'max'

/// A helper class to hold all calculated values from a LiveProfit object.
class SymbolCalculations {
  final LiveProfit liveData;

  // --- Helper Methods ---
  int _detectFeedDecimals(double value) {
    // This is the same logic from your NewTradingItem
    final s = value.toString();
    if (!s.contains('.')) return 0;
    final part = s.split('.')[1];
    // cap between 2–5 for safety
    return part.length.clamp(2, 5);
  }

  // --- Constructor ---
  SymbolCalculations(this.liveData) {
    // Initialize all fields when the object is created

    // Use the double values directly
    bidValue = liveData.bid;
    askValue = liveData.ask;

    // Detect decimals from the 'ask' double
    decimals = _detectFeedDecimals(askValue);

    // Calculate spread
    spread = (askValue - bidValue).abs();

    // Use liveData.low/high if they exist, or calculate a default
    // (Assuming your LiveProfit model might also have optional low/high doubles)
    // If not, you can remove this or adjust as needed.
    // final double? liveLow = liveData.low;
    // final double? liveHigh = liveData.high;

    // lowValue = (liveLow != null && liveLow != 0.0) ? liveLow : (bidValue * 0.999);
    // highValue = (liveHigh != null && liveHigh != 0.0) ? liveHigh : (askValue * 1.001);

    // --- Simplified version if you DON'T have low/high in LiveProfit ---
    lowValue = (bidValue * 0.999);
    highValue = (askValue * 1.001);
  }

  // --- Public Calculated Fields ---
  // These are the final values you will use in your UI
  late final int decimals;
  late final double bidValue;
  late final double askValue;
  late final double spread;
  late final double lowValue;
  late final double highValue;
}