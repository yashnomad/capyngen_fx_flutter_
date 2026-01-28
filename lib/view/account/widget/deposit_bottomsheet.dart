import 'package:exness_clone/theme/app_colors.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/view/account/withdraw_deposit/deposit_fund_screen.dart';
import 'package:exness_clone/view/account/withdraw_deposit/widget/deposit_popup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widget/color.dart';

void depositCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColor.mediumGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            const Text(
              'Choose payment method',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _PaymentOptionTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Crypto wallet',
              trailingText: '0.00 USD',
              onTap: () {
                Navigator.pop(context);
                // context.push('/cryptoWallet');
                context.push('/depositCrypto');
              },
            ),
            Divider(
              height: 10,
              thickness: 0.5,
              color: AppColor.greyColor,
            ),
            _PaymentOptionTile(
              icon: Icons.file_download_outlined,
              title: 'All payment methods',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => DepositFundsScreen()));
                // Navigator.pop(context);
                // UIBottomSheets.showBankDialog(context, DepositFundsPopup());
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColor.lightGrey,
        child: Icon(
          icon,
          color: AppColor.blackColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: trailingText != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              ],
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      onTap: onTap,
    );
  }
}
