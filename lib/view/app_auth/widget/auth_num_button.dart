import 'package:flutter/material.dart';

class AppNumberButton extends StatelessWidget {
  final String value;
  final VoidCallback? onPressed;

  const AppNumberButton({
    super.key,
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDelete = value == 'delete';

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child:  Center(
          child: isDelete
              ? const Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 28,
          )
              :  Container(
            
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
      )
    );
  }
}
