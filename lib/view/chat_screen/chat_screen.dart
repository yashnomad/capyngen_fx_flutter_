import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../config/flavor_assets.dart';
import '../../theme/app_colors.dart';
import '../../widget/color.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;

  final List<Map<String, String>> messages = [
    {
      'sender': 'bot',
      'message':
      'I’m your ${FlavorAssets.appName} AI Assistant, and I’m ready to help you with anything you need. Just type your question.',
      'time': 'Just now'
    }
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    String formattedTime = DateFormat('h:mm a').format(DateTime.now());

    setState(() {
      messages.add({
        'sender': 'user',
        'message': _controller.text.trim(),
        'time': formattedTime
      });
      _controller.clear();
      _charCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {

    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(

      backgroundColor: context.chatScaffoldColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: context.chatAppBackgroundColor,
        title: Row(
          children: [
            Text(
              '${FlavorAssets.appName} Assistant',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.hand_thumbsup,
                size: 18,
                color: context.themeColor,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 20),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(child: Divider(color: AppColor.mediumGrey)),
                  const SizedBox(width: 10),
                  Text(
                    "Chat started at 17:31",
                    style: TextStyle(
                        color: context.chatTextColor, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Divider(color: AppColor.mediumGrey)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  bool isBot = msg['sender'] == 'bot';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isBot
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isBot)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                              AssetImage(AppVector.bot),
                            ),
                          ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isBot
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isBot
                                      ? Colors.grey.shade100
                                      : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg['message'] ?? '',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.blackColor),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isBot
                                    ? "Bot • ${msg['time']}"
                                    : msg['time'] ?? '',
                                style: TextStyle(
                                    color:
                                   context.chatTextColor,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ✅ Chat Input Field
            Container(
              color: context.chatBoxDecorationColor,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),
                      maxLength: 400,
                      maxLines: 3,
                      minLines: 1,
                      cursorWidth: 1,
                      cursorHeight: 20,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(400),
                      ],
                      onChanged: (text) => setState(() => _charCount = text.length),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "Type your message",
                        hintStyle: TextStyle(fontSize: 12,color: AppColor.greyColor),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.mediumGrey)
                        ),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColor.mediumGrey)
                          ),
                        filled: true,
                        fillColor: context.chatScaffoldColor,
                        counterText: "",
                        suffixText:'$_charCount/400',
                        suffixStyle: TextStyle(fontSize: 11,color: AppColor.greyColor)

                      ),
                    ),

                  ),
                  const SizedBox(width: 6),

                  _controller.text.trim().isNotEmpty? IconButton(
                    style: IconButton.styleFrom(backgroundColor: AppColor.yellowColor),
                    onPressed: _sendMessage,
                    icon: Icon(
                      CupertinoIcons.paperplane,
                      color: AppColor.blackColor,
                      size: 20,

                    ),
                  ):IconButton(
                    onPressed:null,
                    icon: Icon(
                        CupertinoIcons.paperplane,
                        color: AppColor.greyColor,
                      size: 20,

                    ),
                  )

                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
