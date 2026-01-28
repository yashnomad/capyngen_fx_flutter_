
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/view/chat_screen/chat_screen.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageAppbar extends StatelessWidget implements PreferredSizeWidget {



  const MessageAppbar({
    super.key,

  });

  @override
  Widget build(BuildContext context) {


    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
       color:   context.backgroundColor,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed:  () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen()) );

            },
            icon:  Icon(CupertinoIcons.chat_bubble_text,color: context.themeColor,),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
