// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// import 'candle_data.dart';
//
// class RealtimeChartWidget extends StatefulWidget {
//   final List<CandleData> candleData;
//   final String chartType;
//   final Color primaryColor;
//
//   const RealtimeChartWidget({
//     super.key,
//     required this.candleData,
//     this.chartType = 'candle',
//     this.primaryColor = Colors.blue,
//   });
//
//   @override
//   State<RealtimeChartWidget> createState() => _RealtimeChartWidgetState();
// }
//
// class _RealtimeChartWidgetState extends State<RealtimeChartWidget> {
//   @override
//   Widget build(BuildContext context) {
//     if (widget.candleData.isEmpty) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//
//     return Container(
//       height: 300,
//       padding: const EdgeInsets.all(16),
//       child:
//           widget.chartType == 'line' ? _buildLineChart() : _buildCandleChart(),
//     );
//   }
//
//   Widget _buildLineChart() {
//     final spots = widget.candleData.asMap().entries.map((entry) {
//       return FlSpot(entry.key.toDouble(), entry.value.close);
//     }).toList();
//
//     return LineChart(
//       LineChartData(
//         gridData: FlGridData(
//           show: true,
//           drawVerticalLine: true,
//           horizontalInterval: 1,
//           verticalInterval: 1,
//           getDrawingHorizontalLine: (value) {
//             return FlLine(
//               color: Colors.grey.withOpacity(0.3),
//               strokeWidth: 1,
//             );
//           },
//           getDrawingVerticalLine: (value) {
//             return FlLine(
//               color: Colors.grey.withOpacity(0.3),
//               strokeWidth: 1,
//             );
//           },
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 30,
//               interval: spots.length / 5,
//               getTitlesWidget: (value, meta) {
//                 final index = value.toInt();
//                 if (index >= 0 && index < widget.candleData.length) {
//                   final candle = widget.candleData[index];
//                   return SideTitleWidget(
//                     fitInside: meta.axisSide,
//                     meta: null,
//                     child: Text(
//                       '${candle.time.hour}:${candle.time.minute.toString().padLeft(2, '0')}',
//                       style: const TextStyle(fontSize: 10),
//                     ),
//                   );
//                 }
//                 return const Text('');
//               },
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 5,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   value.toStringAsFixed(0),
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//               reservedSize: 42,
//             ),
//           ),
//         ),
//         borderData: FlBorderData(
//           show: true,
//           border: Border.all(color: const Color(0xff37434d)),
//         ),
//         minX: 0,
//         maxX: spots.length.toDouble() - 1,
//         minY: widget.candleData
//                 .map((e) => e.low)
//                 .reduce((a, b) => a < b ? a : b) -
//             2,
//         maxY: widget.candleData
//                 .map((e) => e.high)
//                 .reduce((a, b) => a > b ? a : b) +
//             2,
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             gradient: LinearGradient(
//               colors: [
//                 widget.primaryColor,
//                 widget.primaryColor.withOpacity(0.5),
//               ],
//             ),
//             barWidth: 2,
//             isStrokeCapRound: true,
//             dotData: FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                 colors: [
//                   widget.primaryColor.withOpacity(0.3),
//                   widget.primaryColor.withOpacity(0.1),
//                 ],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCandleChart() {
//     final minPrice =
//         widget.candleData.map((e) => e.low).reduce((a, b) => a < b ? a : b);
//     final maxPrice =
//         widget.candleData.map((e) => e.high).reduce((a, b) => a > b ? a : b);
//
//     return Container(
//       height: 300,
//       child: CustomPaint(
//         painter: CandlestickPainter(
//           candleData: widget.candleData,
//           minPrice: minPrice - 2,
//           maxPrice: maxPrice + 2,
//         ),
//         size: Size.infinite,
//       ),
//     );
//   }
// }
//
// // Custom painter for candlestick chart
// class CandlestickPainter extends CustomPainter {
//   final List<CandleData> candleData;
//   final double minPrice;
//   final double maxPrice;
//
//   CandlestickPainter({
//     required this.candleData,
//     required this.minPrice,
//     required this.maxPrice,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (candleData.isEmpty) return;
//
//     final candleWidth = size.width / candleData.length * 0.8;
//     final priceRange = maxPrice - minPrice;
//
//     for (int i = 0; i < candleData.length; i++) {
//       final candle = candleData[i];
//       final x = (i + 0.5) * size.width / candleData.length;
//
//       final openY =
//           size.height - ((candle.open - minPrice) / priceRange * size.height);
//       final closeY =
//           size.height - ((candle.close - minPrice) / priceRange * size.height);
//       final highY =
//           size.height - ((candle.high - minPrice) / priceRange * size.height);
//       final lowY =
//           size.height - ((candle.low - minPrice) / priceRange * size.height);
//
//       final isGreen = candle.close > candle.open;
//       final color = isGreen ? Colors.green : Colors.red;
//
//       final paint = Paint()
//         ..color = color
//         ..style = PaintingStyle.fill;
//
//       final linePaint = Paint()
//         ..color = color
//         ..strokeWidth = 1;
//
//       // Draw wick (high-low line)
//       canvas.drawLine(
//         Offset(x, highY),
//         Offset(x, lowY),
//         linePaint,
//       );
//
//       // Draw candle body
//       final bodyTop = isGreen ? closeY : openY;
//       final bodyBottom = isGreen ? openY : closeY;
//       final bodyHeight = (bodyBottom - bodyTop).abs();
//
//       if (bodyHeight < 1) {
//         // Draw line for doji candles
//         canvas.drawLine(
//           Offset(x - candleWidth / 2, openY),
//           Offset(x + candleWidth / 2, openY),
//           linePaint,
//         );
//       } else {
//         // Draw rectangle for normal candles
//         canvas.drawRect(
//           Rect.fromLTWH(
//             x - candleWidth / 2,
//             bodyTop,
//             candleWidth,
//             bodyHeight,
//           ),
//           paint,
//         );
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
