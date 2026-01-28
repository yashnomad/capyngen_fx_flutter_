// models/feedback_model.dart

class FeedbackRequest {
  final int rating;
  final String liked;
  final String improvements;
  final String? email;

  FeedbackRequest({
    required this.rating,
    required this.liked,
    required this.improvements,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'liked': liked,
      'improvements': improvements,
      if (email != null && email!.isNotEmpty) 'email': email,
    };
  }

  // Validation helpers
  bool get isValid {
    return rating > 0 &&
        rating <= 5 &&
        liked.trim().isNotEmpty &&
        improvements.trim().isNotEmpty;
  }

  String? get validationError {
    if (rating <= 0 || rating > 5) {
      return 'Please rate your experience';
    }
    if (liked.trim().isEmpty) {
      return 'Please tell us what you liked';
    }
    if (improvements.trim().isEmpty) {
      return 'Please share your suggestions for improvement';
    }
    if (email != null && email!.isNotEmpty && !_isValidEmail(email!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}

class FeedbackResponse {
  final bool success;
  final String message;

  FeedbackResponse({
    required this.success,
    required this.message,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
    };
  }
}

// Helper class for feedback rating
class FeedbackRating {
  final int value;
  final String label;
  final String emoji;

  const FeedbackRating({
    required this.value,
    required this.label,
    required this.emoji,
  });

  static const List<FeedbackRating> ratings = [
    FeedbackRating(value: 1, label: "Very Bad", emoji: "😡"),
    FeedbackRating(value: 2, label: "Bad", emoji: "😞"),
    FeedbackRating(value: 3, label: "Good", emoji: "🙂"),
    FeedbackRating(value: 4, label: "Very Good", emoji: "😊"),
    FeedbackRating(value: 5, label: "Excellent", emoji: "😍"),
  ];

  static FeedbackRating? getRating(int value) {
    try {
      return ratings.firstWhere((rating) => rating.value == value);
    } catch (e) {
      return null;
    }
  }

  static String getLabel(int rating) {
    return getRating(rating)?.label ?? "";
  }

  static String getEmoji(int rating) {
    return getRating(rating)?.emoji ?? "";
  }
}