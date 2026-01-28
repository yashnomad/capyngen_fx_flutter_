import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/account/transaction/transaction_history.dart';
import 'package:exness_clone/view/profile/profile_screen.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class OpenTicket extends StatefulWidget {
  const OpenTicket({super.key});

  @override
  State<OpenTicket> createState() => _OpenTicketState();
}

class _OpenTicketState extends State<OpenTicket> {
  final List<Map<String, dynamic>> issues = [
    {
      'icon': Icons.account_balance_wallet_outlined,
      'title': 'Payments',
      'description':
          'Deposit/Withdrawal issues, Internal transfer problem, Non-supported token/blockchain.'
    },
    {
      'icon': Icons.bar_chart,
      'title': 'Trading',
      'description':
          'MT4/5 Connection issues, Execution, Incorrect charges, Stop Out, Pricing, Incorrect swap calculation/deduction.'
    },
    {
      'icon': Icons.settings,
      'title': 'Technical',
      'description':
          'Authentication/Verification issues, Emails management, Technical issues with documents, Other technical issues.'
    },
    {
      'icon': Icons.dns, // Representing VPS
      'title': 'VPS',
      'description':
          'VPS/Terminal settings problem with language and timezone, High ping issues, Other VPS issues.'
    },
    {
      'icon': Icons.groups, // Representing Partnerships
      'title': 'Partnerships',
      'description':
          'Registration and Inquiry, Affiliate/Partnership rewards, Client not under partner, Other partnerships issues.'
    },
    {
      'icon': Icons.card_giftcard, // Representing Bonus
      'title': 'Bonus',
      'description':
          'Bonus not updated in Personal Area, Cancel bonus program, Other bonus issues.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    void showTransactionDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Go to Transaction History',
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: 1.2,
                            height: 0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'For assistance on your transactions press continue button, open the transaction and select “support request”.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColor.yellowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionHistory(tradeUserId: '',)));
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace:
            Container(color: context.backgroundColor),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open a ticket',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 15),
              Text(
                'Please select a topic for your inquiry so we can assist you better.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 20),
              Column(
                spacing: 20,
                children: List.generate(issues.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        showTransactionDialog(context);
                      } else if (index == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TradingTicket()));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColor.mediumGrey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(issues[index]['icon']),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${issues[index]['title']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 22),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${issues[index]['description']}',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TradingTicket extends StatefulWidget {
  const TradingTicket({super.key});

  @override
  State<TradingTicket> createState() => _TradingTicketState();
}

class _TradingTicketState extends State<TradingTicket> {
  Map<String, String?> selectedOptions = {};

  bool _showError = false;

  final List<Map<String, dynamic>> ticketCategories = [
    {
      'title': 'MT4/5 issues',
      'options': [
        'Frequent disconnections / reconnections on the terminal',
        'Unable to connect / log in to my trading account',
      ],
    },
    {
      'title': 'Execution',
      'options': [
        'Error message during opening / closing / modifying of order(s)',
        'Pending order price reached but trade not executed',
        'Incorrect close price',
        'Slippage order closed / opened on different price than requested',
      ],
    },
    {
      'title': 'Incorrect charges',
      'options': [
        'Margin charges / calculations',
        'Trading commissions',
        'Profit / loss calculations',
        'Missing null compensations',
      ],
    },
    {
      'title': 'Stop Out',
      'options': [
        'Deposit / internal transfer delay',
        'Incorrect close price',
        'Slippage order closed / opened on different price than requested',
      ],
    },
    {
      'title': 'Pricing',
      'options': [
        'Price delay / gaps',
        'Price spike / mismatch',
        'Incorrect high / low prices',
      ],
    },
    {
      'title': 'Incorrect swap calculation/deduction',
      'options': [
        'Incorrect swap deducted/added',
        'Swap calculated on wrong volume/date',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
            color: context.backgroundColor),
        leading: IconButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          icon: const Icon(Icons.close),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        children: [
          const Text(
            'Please select the ticket category',
            style:
                TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 0),
          ),
          const SizedBox(height: 24),
          ...ticketCategories.map((entry) {
            final String categoryTitle = entry['title'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate((entry['options'] as List).length, (index) {
                  final option = entry['options'][index];
                  final isSelected = selectedOptions[categoryTitle] == option;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedOptions[categoryTitle] = option;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.circle_outlined,
                            color: isSelected ? Colors.blueGrey : AppColor.greyColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          }),
          if (_showError)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Category required',
                style: TextStyle(
                  color: AppColor.redColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(
            height: 15,
          ),
          Row(
            spacing: 10,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      context.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppFlavorColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onPressed: () {
                  bool anySelected = selectedOptions.values.any((value) => value != null);

                  if (!anySelected) {
                    setState(() {
                      _showError = true; // Show error
                    });
                    return;
                  }

                  setState(() {
                    _showError = false; // Hide error if all good
                  });

                  Navigator.push(
                    context,
                    SlidePageRoute(page: SubmitIssueForm()),
                  );
                },
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubmitIssueForm extends StatefulWidget {
  const SubmitIssueForm({super.key});

  @override
  _SubmitIssueFormState createState() => _SubmitIssueFormState();
}

class _SubmitIssueFormState extends State<SubmitIssueForm> {
  String category = "Partnerships";
  String issue = "Client not under partner";
  final TextEditingController descriptionController = TextEditingController();

  PlatformFile? selectedFile;

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'txt',
        'log',
        'pdf',
        'har',
        'png',
        'jpg',
        'jpeg',
        'mp4',
        'mpeg'
      ],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;

      if (file.size > 60 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File exceeds 60MB limit")),
        );
        return;
      }

      setState(() {
        selectedFile = file;
      });
    }
  }

  void deleteFile() {
    setState(() {
      selectedFile = null;
    });
  }

  void submit() {
    // TODO: Implement submission logic
    print("Submitted with description: ${descriptionController.text}");
    if (selectedFile != null) {
      print("File uploaded: ${selectedFile!.name}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
            color: context.backgroundColor),
        leading: IconButton(
          onPressed: (){
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Please provide details of your issue",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 24, height: 0)),
              SizedBox(height: 16),
              Text("Category",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, color: AppColor.greyColor)),
              SizedBox(height: 4),
              Text(category),
              SizedBox(height: 16),
              Text("Specific issue",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, color: AppColor.greyColor)),
              SizedBox(height: 4),
              InkWell(
                onTap: () {},
                child: Text(issue,
                    style: TextStyle(
                        color: AppColor.blueColor,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColor.blueColor,
                        decorationThickness: 1.5,
                        fontWeight: FontWeight.w500)),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 16),
              Text(
                "Please describe the issue in more detail",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 4),
              TextField(
                controller: descriptionController,
                maxLength: 1000,
                decoration: InputDecoration(border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.mediumGrey)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1)
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Upload (optional)",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 4,
              ),
              GestureDetector(
                onTap: pickFile,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.greyColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 32),
                      SizedBox(height: 8),
                      Text("Drag & drop file(s) or browse",
                          style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      Text(
                          "TXT, LOG, PDF, HAR, PNG, JPG, JPEG, MP4, MPEG (max. 5 files, max. size 60 mb for all files)",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                              fontSize: 11, color: Colors.grey.shade600),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
              if (selectedFile != null)
                Container(
                  margin: EdgeInsets.only(top: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.greenColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.check_mark_circled, color: AppColor.greenColor),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${selectedFile!.name} (${(selectedFile!.size / 1024).toStringAsFixed(2)} Kb)",
                          style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: deleteFile,
                        child:
                            Text("Delete", style: TextStyle(color: AppColor.redColor,fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              Row(
                spacing: 10,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          context.scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppFlavorColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
