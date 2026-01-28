import 'package:flutter/material.dart';

class PerformanceModel {
  PerformanceModel({
    required this.success,
    required this.data,
  });

  final bool success;
  final List<Datum> data;

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      success: json["success"] ?? false,
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$success, $data";
  }
}

class Datum {
  Datum({
    required this.label,
    required this.total,
    required this.color,
    required this.today,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final num total;
  final String color;
  final num today;

  final Color backgroundColor;
  final Color textColor;

  factory Datum.fromJson(Map<String, dynamic> json) {
    String colorString = json["color"] ?? "";

    final parsedColors = _parseColorString(colorString);

    return Datum(
      label: json["label"] ?? "",
      total: json["total"] ?? 0,
      color: colorString,
      today: json["today"] ?? 0,
      backgroundColor: parsedColors['bg']!,
      textColor: parsedColors['text']!,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        "label": label,
        "total": total,
        "color": color,
        "today": today,
      };

  @override
  String toString() {
    return "$label, $total, $color, $today";
  }

//   static Map<String, Color> _parseColorString(String colorString) {
//     Color bg = Colors.grey.shade100;
//     Color text = Colors.grey.shade800;
//
//     if (colorString.contains("blue")) {
//       bg = Colors.blue.shade100;
//       text = Colors.blue.shade800;
//     } else if (colorString.contains("sky")) {
//       bg = Colors.lightBlue.shade100;
//       text = Colors.lightBlue.shade900;
//     } else if (colorString.contains("orange")) {
//       bg = Colors.orange.shade100;
//       text = Colors.orange.shade800;
//     } else if (colorString.contains("lime") || colorString.contains("green")) {
//       bg = Colors.lightGreen.shade100;
//       text = Colors.lightGreen.shade800;
//     } else if (colorString.contains("rose") || colorString.contains("red")) {
//       bg = Colors.pink.shade100;
//       text = Colors.pink.shade800;
//     } else if (colorString.contains("purple")) {
//       bg = Colors.purple.shade100;
//       text = Colors.purple.shade800;
//     } else if (colorString.contains("pink")) {
//       bg = Colors.pinkAccent.shade100;
//       text = Colors.pinkAccent.shade700;
//     } else if (colorString.contains("gray")) {
//       bg = Colors.grey.shade200;
//       text = Colors.grey.shade800;
//     }
//
//     return {'bg': bg, 'text': text};
//   }
// }

  static Map<String, Color> _parseColorString(String colorString) {
    // We will handle the actual theme-switching logic in the UI or use a helper
    // But for the model, let's define base MaterialColors
    MaterialColor baseColor = Colors.grey;

    if (colorString.contains("blue"))
      baseColor = Colors.blue;
    else if (colorString.contains("sky"))
      baseColor = Colors.lightBlue;
    else if (colorString.contains("orange"))
      baseColor = Colors.orange;
    else if (colorString.contains("green") || colorString.contains("lime"))
      baseColor = Colors.green;
    else if (colorString.contains("red") || colorString.contains("rose"))
      baseColor = Colors.red;
    else if (colorString.contains("purple")) baseColor = Colors.purple;

    // Return the base color. We will adjust the shades in the UI widget.
    return {'bg': baseColor, 'text': baseColor};
  }
}