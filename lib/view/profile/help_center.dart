import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/view/chat_screen/chat_screen.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {

  bool showMore = false;


  String selectedStatus = "All";
  final List<String> statuses = [
    "All",
    "New",
    "In progress",
    "Action Required",
    "Escalated to provider"
  ];



  @override
  Widget build(BuildContext context) {

    List<Widget> additionalTiles = [

      _languageTile('French'),
      _languageTile('Swahili'),
      _languageTile('Indonesian'),
      _languageTile('Korean'),
      _languageTile('Portuguese'),
      _languageTile('Spanish'),
    ];


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        flexibleSpace: Container(
            color:   context.backgroundColor,
        ),
        leading: IconButton(
          onPressed:  () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Support hub',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w700,letterSpacing: 1.3),),
              SizedBox(height: 10,),
              Container(
               decoration: BoxDecoration(
                   color:context.scaffoldBackgroundColor,
                 borderRadius: BorderRadius.circular(10)
               ),
               child: Padding(
                 padding: const EdgeInsets.all(25),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'How can we help you?',
                       style: TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       'Your one-stop solution for all your needs. Find answers, troubleshoot issues, and explore guides.',
                       style: TextStyle(
                         fontSize: 13,
                         fontWeight: FontWeight.w500
                       ),
                     ),
                     const SizedBox(height: 20),
                     SizedBox(
                       height: 45,
                       child: TextField(
                         decoration: InputDecoration(
                           hintText: 'Please enter your question or keyword',
                           hintStyle: TextStyle(color: AppColor.greyColor,fontSize: 13),
                           filled: true,
                           isDense: true,
                           fillColor:context.backgroundColor,
                           suffixIcon: Container(
                             margin: const EdgeInsets.all(6),
                             decoration: BoxDecoration(
                               color: AppFlavorColor.primary,
                               borderRadius: BorderRadius.circular(6),
                             ),
                             child:Icon(CupertinoIcons.search, color: AppColor.blackColor,size: 20),
                           ),
                           contentPadding: EdgeInsets.symmetric(horizontal: 16),
                           border: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(10),
                           ),
                           enabledBorder: OutlineInputBorder(
                               borderSide: BorderSide(color: AppColor.mediumGrey)
                           ),
                           focusedBorder: OutlineInputBorder(
                               borderSide: BorderSide(color: AppColor.mediumGrey)
                           ),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
              SizedBox(height: 25,),
              Text('My tickets',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w700,letterSpacing: 1.3),),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColor.mediumGrey),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need assistance?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the form and we will reply within 24 hours.',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          color: AppColor.greyColor
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 45,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: TextStyle(color: AppColor.greyColor,fontSize: 13),
                            filled: true,
                            isDense: true,
                            fillColor:context.backgroundColor,
                            prefixIcon: Icon(CupertinoIcons.search, color: AppColor.greyColor,size: 20),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColor.mediumGrey)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 0.8)
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                  Container(
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      border: Border.all(color: AppColor.mediumGrey),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                    child: PopupMenuButton<String>(
                      position: PopupMenuPosition.under,

                     elevation: 1,
                      onSelected: (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (BuildContext context) {
                        return statuses.map((String status) {
                          return PopupMenuItem<String>(

                            value: status,
                            child: Text(status),
                          );
                        }).toList();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Active statuses: $selectedStatus",
                            style: TextStyle(
                              fontSize: 14,

                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                      SizedBox(height: 30,),
                      
                      Center(child: Icon(CupertinoIcons.exclamationmark_circle,size: 40,color: AppColor.greyColor,)),
                      SizedBox(height: 10,),
                      Center(child: Text("You don't have any tickets",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),)),

                      SizedBox(height: 10,),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle ticket creation logic here
                    },
                    icon:  Icon(Icons.add, color: AppColor.blackColor),
                    label:  Text(
                      'Open a ticket',
                      style: TextStyle(color: AppColor.blackColor,fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppFlavorColor.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25,),
              Text('Contact us',style: TextStyle(fontSize: 26,fontWeight: FontWeight.w700,letterSpacing: 1.3),),

              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColor.mediumGrey,)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Phone Section
                      const Text(
                        'Phone',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                       Text(
                        'Want to speak to our support team? Call us on\n000-800-100-4378 (toll free),\n+917901658940 (local)',
                        style: TextStyle(color: AppColor.greyColor,fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Live Chat Section
                      const Text(
                        'Live chat',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                       Text(
                        'Can’t find the answers you’re looking for? Start by chatting with our Intelligent Assistant.',
                        style: TextStyle(color: AppColor.greyColor),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, SlidePageRoute(page: ChatScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100],
                          minimumSize: Size(0, 35),
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Start chat',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Divider(color: AppColor.mediumGrey,),
                      const SizedBox(height: 10),

                      // Working hours
                      const Text(
                        'Working hours',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 8),

                      Theme(
                        data: ThemeData(dividerColor: AppColor.transparent),
                        child: ExpansionTile(

                          iconColor: AppColor.greyColor,
                          title: const Text(
                            'English, Thai, Chinese, Vietnamese,\nArabic, Bengali, Hindi, Urdu',
                            style: TextStyle(fontSize: 13),
                          ),

                          tilePadding: EdgeInsets.zero,
                          children: [
                            Divider(color: AppColor.mediumGrey),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text(
                                  'Availability: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  'Online 24/7',
                                  style: TextStyle(color: AppColor.greenColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),

                      Divider(color: AppColor.mediumGrey,),

                      // Show more section (just UI)
                      if (showMore) ...additionalTiles,

                      const SizedBox(height: 10),

                      // Show more / less toggle
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showMore = !showMore;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(showMore ? "Show less" : "Show more"),
                                Icon(showMore
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _languageTile(String language) {
    return Column(
      children: [
        Theme(
          data: ThemeData(dividerColor: AppColor.transparent),
          child: ExpansionTile(

            dense: true,
            tilePadding: EdgeInsets.zero,
            title: Text(language, style: const TextStyle(fontSize: 13)),
            children: [
              Row(
                children: [
                  Text(
                    'Availability: ',
                    style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    'Online 24/7',
                    style: TextStyle(color: AppColor.greenColor, fontSize: 13),
                  ),
                ],
              )
            ],
          ),
        ),
        Divider(color: AppColor.mediumGrey),
      ],
    );
  }
}
