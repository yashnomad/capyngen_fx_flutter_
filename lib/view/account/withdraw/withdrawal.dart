import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/utils/bottom_sheets.dart';
import 'package:exness_clone/view/account/withdraw_deposit/widget/withdraw_popup.dart';
import 'package:exness_clone/widget/color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../widget/transfer_option_card.dart';

class WithdrawalChooseScreen extends StatefulWidget {
  const WithdrawalChooseScreen({super.key});

  @override
  State<WithdrawalChooseScreen> createState() => _WithdrawalChooseScreenState();
}

class _WithdrawalChooseScreenState extends State<WithdrawalChooseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: MessageAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Withdrawal',
                style: TextStyle(
                    fontSize: 30,
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 20),
              Text(
                'All payment methods',
                style: TextStyle(
                    fontSize: 24,
                    color: AppColor.blackColor,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                spacing: 15,
                children: List.generate(1, (index) {
                  return GestureDetector(
                    // onTap: () => UIBottomSheets.showBankDialog(
                    //     context, WithdrawFundsPopup()),
                    onTap: () => context.push('/withdrawFundsScreen'),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColor.greyColor, width: 0.3)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  AppVector.binance,
                                  height: 50,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'BinancePay',
                                        style: TextStyle(
                                            color: AppColor.blackColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16),
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Processing time ',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.greyColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              'Instant - 30 minutes',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.blackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Fee ',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.greyColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              '0 %',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.blackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Limits ',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.greyColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Flexible(
                                            child: Text(
                                              '10 - 20,000 USD',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor.blackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(
                height: 40,
              ),
              Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Transfer",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColor.blackColor)),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('internalTransfer');
                    },
                    child: const TransferOptionCard(
                      icon: Icons.swap_horiz,
                      title: "Between your accounts",
                      processingTime: "Instant - 1 day",
                      fee: "0 %",
                      limits: "1 - 1,000,000 USD",
                      active: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Verification required",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColor.blackColor)),
                  const TransferOptionCard(
                    icon: Icons.laptop_mac,
                    title: "Online Bank",
                    processingTime: "Instant - 3 days",
                    fee: "0 %",
                    limits: "15 - 1,000 USD",
                  ),
                  const TransferOptionCard(
                    icon: Icons.currency_exchange,
                    title: "Tether (USDT ERC20)",
                    processingTime: "Instant - 15 minutes",
                    fee: "0 %",
                    limits: "100 - 1,000,000 USD",
                  ),
                  const TransferOptionCard(
                    icon: Icons.currency_bitcoin,
                    title: "Tether (USDT TRC20)",
                    processingTime: "Instant - 15 minutes",
                    fee: "0 %",
                    limits: "100 - 1,000,000 USD",
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
