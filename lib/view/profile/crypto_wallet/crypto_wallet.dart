import 'package:exness_clone/view/account/withdraw/withdrawal.dart';
import 'package:exness_clone/view/profile/crypto_withdrawal.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:exness_clone/widget/slidepage_navigate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constant/app_vector.dart';
import '../../../theme/app_colors.dart';
import 'model/wallets.dart';

class CryptoWallet extends StatefulWidget {
  const CryptoWallet({super.key});

  @override
  State<CryptoWallet> createState() => _CryptoWalletState();
}

class _CryptoWalletState extends State<CryptoWallet> {
  final List<String> options = ["Account name", "Balance"];
  String selectedOption = "Account name";

  final GlobalKey _popupKey = GlobalKey();

  void _showPopupMenu() {
    final RenderBox renderBox =
        _popupKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    showMenu(
      color: AppColor.whiteColor,
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height + 5,
        offset.dx + renderBox.size.width,
        0,
      ),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(
              color: AppColor.blackColor,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedOption = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness== Brightness.dark;

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: MessageAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1EC),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset(AppVector.c, height: 60),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("How to crypto_deposit with crypto",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: AppColor.blackColor)),
                        SizedBox(height: 4),
                        Text(
                            "Check out our step-by-step guides on crypto deposits",
                            style: TextStyle(
                                fontSize: 13, color: AppColor.blackColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Crypto wallet",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColor.blackColor),
            ),
            const SizedBox(height: 8),
            Text("Total balance", style: TextStyle(color: AppColor.greyColor)),
            Text("0.00 USD",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColor.blackColor)),
            const SizedBox(height: 40),
            GestureDetector(
              key: _popupKey,
              onTap: _showPopupMenu,
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.42,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.lightGrey, width: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_outlined,
                      size: 16,
                      color: AppColor.blackColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      selectedOption,
                      style: TextStyle(
                        color: AppColor.blackColor,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColor.greyColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(wallets.length, (index) {
              final wallet = wallets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.lightGrey, width: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${wallet['name']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackColor,
                        )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${wallet['balance']} ${wallet['symbol']}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColor.blackColor,
                          ),
                        ),
                      ],
                    ),
                    Text("≈ ${wallet['usdValue']} USD",
                        style: TextStyle(color: AppColor.greyColor)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    SlidePageRoute(page: CryptoWithdrawal()));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                    CupertinoIcons.arrow_up_right_circle,
                                    color: AppColor.blackColor),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text("Withdrawal",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.blackColor,
                                )),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.swap_horiz_sharp,
                                  color: AppColor.blackColor),
                            ),
                            SizedBox(height: 4),
                            Text("Transfer",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.blackColor,
                                )),
                          ],
                        ),
                        GestureDetector(
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColor.yellowColor,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.arrow_circle_down,
                                    color: AppColor.blackColor),
                              ),
                              const SizedBox(height: 4),
                              Text("Deposit",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColor.blackColor,
                                  )),
                            ],
                          ),
                          onTap: () {
                            if (index == 0) {
                              context.push('/depositCrypto');
                            } else {
                              return;
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
