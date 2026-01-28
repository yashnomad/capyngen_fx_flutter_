
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../network/api_service.dart';
import '../model/feedback_model.dart';



// States
abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackSuccess extends FeedbackState {
  final FeedbackResponse response;

  const FeedbackSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

class FeedbackValidationError extends FeedbackState {
  final String message;

  const FeedbackValidationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit() : super(FeedbackInitial());

  // Submit feedback
  Future<bool> submitFeedback({
    required int rating,
    required String liked,
    required String improvements,
    String? email,
  }) async {
    try {
      // Create feedback request
      final feedbackRequest = FeedbackRequest(
        rating: rating,
        liked: liked.trim(),
        improvements: improvements.trim(),
        email: email?.trim(),
      );

      // Validate the request
      final validationError = feedbackRequest.validationError;
      if (validationError != null) {
        emit(FeedbackValidationError(validationError));
        return false;
      }

      // Show loading state
      emit(FeedbackLoading());

      // Submit to API
      final response = await ApiService.feedback(feedbackRequest.toJson());

      if (response.success && response.data != null) {
        final feedbackResponse = FeedbackResponse.fromJson(response.data!);
        emit(FeedbackSuccess(feedbackResponse));
        return true;
      } else {
        emit(FeedbackError(response.message ?? 'Failed to submit feedback'));
        return false;
      }
    } catch (e) {
      emit(FeedbackError('Error submitting feedback: ${e.toString()}'));
      return false;
    }
  }

  // Submit with FeedbackRequest object
  Future<bool> submitFeedbackRequest(FeedbackRequest request) async {
    return await submitFeedback(
      rating: request.rating,
      liked: request.liked,
      improvements: request.improvements,
      email: request.email,
    );
  }

  // Reset state
  void reset() {
    emit(FeedbackInitial());
  }

  // Clear error state
  void clearError() {
    if (state is FeedbackError || state is FeedbackValidationError) {
      emit(FeedbackInitial());
    }
  }

  // Check if currently loading
  bool get isLoading => state is FeedbackLoading;

  // Check if last submission was successful
  bool get isSuccess => state is FeedbackSuccess;

  // Get last success message
  String? get successMessage {
    if (state is FeedbackSuccess) {
      return (state as FeedbackSuccess).response.message;
    }
    return null;
  }

  // Get current error message
  String? get errorMessage {
    if (state is FeedbackError) {
      return (state as FeedbackError).message;
    } else if (state is FeedbackValidationError) {
      return (state as FeedbackValidationError).message;
    }
    return null;
  }

  // Validate individual fields (helper methods)
  static String? validateRating(int rating) {
    if (rating <= 0 || rating > 5) {
      return 'Please rate your experience';
    }
    return null;
  }

  static String? validateLiked(String liked) {
    if (liked.trim().isEmpty) {
      return 'Please tell us what you liked';
    }
    if (liked.trim().length < 10) {
      return 'Please provide more detailed feedback (at least 10 characters)';
    }
    return null;
  }

  static String? validateImprovements(String improvements) {
    if (improvements.trim().isEmpty) {
      return 'Please share your suggestions for improvement';
    }
    if (improvements.trim().length < 10) {
      return 'Please provide more detailed suggestions (at least 10 characters)';
    }
    return null;
  }

  static String? validateEmail(String? email) {
    if (email != null && email.isNotEmpty) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        return 'Please enter a valid email address';
      }
    }
    return null;
  }

  // Quick validation for UI
  static bool isFormValid({
    required int rating,
    required String liked,
    required String improvements,
    String? email,
  }) {
    return validateRating(rating) == null &&
        validateLiked(liked) == null &&
        validateImprovements(improvements) == null &&
        validateEmail(email) == null;
  }
}