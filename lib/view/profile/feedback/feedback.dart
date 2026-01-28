import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../helpdesk/helpdesk.dart';
import 'bloc/feedback_cubit.dart';
import 'model/feedback_model.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeedbackCubit(),
      child: const FeedbackView(),
    );
  }
}

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  int _rating = 0;
  final _likeController = TextEditingController();
  final _improveController = TextEditingController();
  final _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _likeController.dispose();
    _improveController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      _rating = 0;
      _likeController.clear();
      _improveController.clear();
      _emailController.clear();
    });
    context.read<FeedbackCubit>().reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: "Share Feedback"),
      body: BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSuccess) {
            SnackBarService.showSnackBar(
              message: state.response.message,
            );
            _resetForm();
          } else if (state is FeedbackError) {
            SnackBarService.showSnackBar(
              message: state.message,
            );
          } else if (state is FeedbackValidationError) {
            SnackBarService.showSnackBar(
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is FeedbackLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColor.blueColor.withOpacity(0.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.feedback_outlined,
                            size: 20,
                            color: AppColor.blueColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Share Your Feedback",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We'd love to hear your thoughts on our platform. Your feedback helps us improve and serve you better.",
                      ),
                      const SizedBox(height: 20),

                      // Rating Section
                      const Text(
                        "Rate your experience *",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        spacing: 10,
                        children: List.generate(5, (index) {
                          return IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: _rating > index
                                    ? const Color(0xFF0B5CF9)
                                    : context.scaffoldBackgroundColor),
                            onPressed: isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _rating = index + 1;
                                    });
                                    context.read<FeedbackCubit>().clearError();
                                  },
                            icon: Icon(
                              Icons.star,
                              color: _rating > index
                                  ? AppColor.whiteColor
                                  : Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white54
                                      : AppColor.mediumGrey,
                              size: 25,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),

                      // Rating Display
                      if (_rating != 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              FeedbackRating.getEmoji(_rating),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              FeedbackRating.getLabel(_rating),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColor.orangeColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // What did you like section
                      const Text(
                        "What did you like most? *",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildTextFormField(
                        controller: _likeController,
                        hintText:
                            "Tell us what you enjoyed about our platform...",
                        maxLines: 3,
                        maxLength: 500,
                        enabled: !isLoading,
                        validator: (value) =>
                            FeedbackCubit.validateLiked(value ?? ''),
                      ),
                      const SizedBox(height: 30),

                      // Improvements section
                      const Text(
                        "How can we improve? *",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildTextFormField(
                        controller: _improveController,
                        hintText: "Share your suggestions for improvement...",
                        maxLines: 3,
                        maxLength: 500,
                        enabled: !isLoading,
                        validator: (value) =>
                            FeedbackCubit.validateImprovements(value ?? ''),
                      ),
                      const SizedBox(height: 30),

                      // Email section
                      const Text(
                        "Email (optional)",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _buildTextFormField(
                        controller: _emailController,
                        hintText: "your.email@example.com",
                        maxLines: 1,
                        enabled: !isLoading,
                        validator: (value) =>
                            FeedbackCubit.validateEmail(value),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "We'll only use this to follow up on your feedback if needed.",
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 30),

                      // Submit Button
                      PremiumAppButton(
                        onPressed: isLoading ? null : _submitFeedback,
                        text: isLoading ? 'Submitting...' : 'Submit Feedback',
                        isLoading: isLoading,
                        showIcon: !isLoading,
                        icon: Icons.arrow_forward_ios,
                        height: 56,
                        borderRadius: 16,
                        backgroundColor: AppFlavorColor.primary,
                        foregroundColor: AppColor.whiteColor,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColor.whiteColor,
                        ),
                      ),

                      /* ElevatedButton(
                        onPressed: isLoading ? null : _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppFlavorColor.primary,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isLoading) ...[
                                 SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColor.whiteColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                 Text(
                                  'Submitting...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.whiteColor,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'Submit Feedback',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.whiteColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColor.whiteColor,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),*/
                      const SizedBox(height: 20),

                      // Reset Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.transparent,
                          side: BorderSide(color: AppColor.lightGrey),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        onPressed: isLoading ? null : _resetForm,
                        label: const Text('Reset'),
                        icon: const Icon(Icons.sync),
                      ),
                      const SizedBox(height: 20),

                      // Footer
                      Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HelpdeskSupportScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            textAlign: TextAlign.center,
                            "Your feedback is important to us and helps improve our services. All submissions are reviewed by our team.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading Overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Submitting your feedback...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    int? maxLength,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: maxLength != null ? 8 : 0,
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        color:
            enabled ? (context.scaffoldBackgroundColor) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.mediumGrey),
      ),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        enabled: enabled,
        validator: validator,
        onChanged: (value) {
          // Clear errors when user starts typing
          context.read<FeedbackCubit>().clearError();
        },
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: AppColor.greyColor),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  void _submitFeedback() async {
    // Clear any existing errors
    context.read<FeedbackCubit>().clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate rating
    if (_rating == 0) {
      SnackBarService.showSnackBar(message: "Please rate your experience.");
      return;
    }

    // Submit feedback
    await context.read<FeedbackCubit>().submitFeedback(
          rating: _rating,
          liked: _likeController.text,
          improvements: _improveController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
        );
  }
}
