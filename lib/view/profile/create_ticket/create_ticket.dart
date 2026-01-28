// screens/create_ticket_screen.dart

import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/snack_bar.dart';
import '../../../widget/simple_appbar.dart';
import 'bloc/ticket_cubit.dart';



class CreateTicket extends StatefulWidget {
  const CreateTicket({super.key});

  @override
  State<CreateTicket> createState() => _CreateTicketState();
}

class _CreateTicketState extends State<CreateTicket> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();

  bool showSubjectError = false;
  bool showDescError = false;

  PlatformFile? _selectedFile;
  final int _maxSizeInMB = 3;

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      showSubjectError = _subjectController.text.trim().isEmpty;
      showDescError = _descController.text.trim().isEmpty;
    });

    if (!showSubjectError && !showDescError) {
      // Show loading and create ticket through cubit
      final success = await context.read<TicketCubit>().createTicket(
        subject: _subjectController.text.trim(),
        description: _descController.text.trim(),
        attachmentFile: _selectedFile,
      );

      if (success) {
        SnackBarService.showSnackBar(
          message: 'Ticket created successfully!',
        );

        // Return to previous screen with success result
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.size > _maxSizeInMB * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${file.name} exceeds 3MB limit')),
        );
        return;
      }

      setState(() {
        _selectedFile = file;
      });
    }
  }

  void _clearForm() {
    _subjectController.clear();
    _descController.clear();
    setState(() {
      showSubjectError = false;
      showDescError = false;
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'New Support Ticket'),
      body: BlocConsumer<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColor.redColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isCreating = state is TicketCreating;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              _subjectController,
                              'Subject',
                              'Subject',
                              'Enter a brief subject for your ticket',
                              showSubjectError,
                              enabled: !isCreating,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              _descController,
                              'Describe your issue / question',
                              'Description',
                              'Please provide as much detail as possible about your issue or question',
                              showDescError,
                              maxLines: 5,
                              enabled: !isCreating,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Attachment',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            _buildFileUploadWidget(isCreating),
                            const SizedBox(height: 20),
                            _buildActionButtons(isCreating),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSupportInfoBox(context),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (isCreating)
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
                              'Creating your ticket...',
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String errorText,
      String hint,
      bool showError, {
        int maxLines = 1,
        bool enabled = true,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: enabled ? null : Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: showError ? Colors.red : AppColor.mediumGrey,
            ),
            color: enabled ? null : Colors.grey[100],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColor.greyColor,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$errorText is required',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFileUploadWidget(bool isCreating) {
    if (_selectedFile == null) {
      return GestureDetector(
        onTap: isCreating ? null : _pickFile,
        child: Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: isCreating ? Colors.grey[100] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.cloud_upload,
                size: 40,
                color: AppColor.greyColor,
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Drag and drop your document or '),
                    TextSpan(
                      text: 'browse',
                      style: TextStyle(
                        color: isCreating ? Colors.grey : AppColor.greenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'JPEG, PNG, PDF - Max 3MB',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _selectedFile!.extension == 'pdf'
                ? Icons.picture_as_pdf
                : Icons.image,
            color: AppColor.blueColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedFile!.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (!isCreating)
            IconButton(
              icon:  Icon(Icons.cancel, color: AppColor.redColor),
              onPressed: () {
                setState(() {
                  _selectedFile = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isCreating) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isCreating ? null : _clearForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              elevation: 0,
              side: BorderSide(color: AppColor.lightGrey),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: isCreating ? null : _handleSubmit,
            icon: isCreating
                ?  SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.whiteColor),
              ),
            )
                : const Icon(Icons.send),
            label: Text(isCreating ? 'Creating...' : 'Submit Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.greenColor,
              foregroundColor: AppColor.whiteColor,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.chat_bubble_2_fill, color: AppColor.greenColor),
              const SizedBox(width: 8),
              const Text(
                'English Support',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Your request will be addressed by our dedicated English support team as soon as possible.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Support Working Hours GMT+0',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffF0F5FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Monday - Friday: 9:00 AM - 6:00 PM\nWeekend: 10:00 AM - 2:00 PM',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffF0F5FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Row(
              children: [
                Icon(Icons.info_outline, color: AppColor.greenColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Average response time for English support is within 2 business hours.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}