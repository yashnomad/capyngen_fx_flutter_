import 'package:exness_clone/constant/trade_data.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_payload.dart';
import 'package:exness_clone/view/account/trade_screen/widget/order_confirmation.dart';
import 'package:exness_clone/view/account/trade_screen/widget/tp_sl_widget.dart';
import 'package:exness_clone/view/account/trade_screen/widget/volume_selector.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/reactive_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_flavor_color.dart';
import '../../../widget/simple_appbar.dart';
import '../../../widget/slidepage_navigate.dart';
import '../btc_chart/btc_chart_screen.dart';

import '../buy_sell_trade/cubit/trade_cubit.dart';
import '../buy_sell_trade/cubit/trade_state.dart';

class NewOrderScreen extends StatefulWidget {
  final String side;
  final String symbol;
  final String id;
  final String sector;

  const NewOrderScreen(
      {super.key,
      required this.side,
      required this.symbol,
      required this.id,
      required this.sector});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  String selectedType = 'Market Execution';
  String? _selectedExecution = 'Market';
  String selectedUnit = 'Lots';
  double sliderValue = 0;
  String selectedSide = 'Buy';
  bool doNotShowAgain = false;
  bool isTakeProfit = false;
  bool isStopLoss = false;
  bool isLimitOrder = false;
  final _limitPriceCtrl = TextEditingController();

  final lotCtrl = TextEditingController(text: '0.1');
  final _tpCtrl = TextEditingController();
  final _slCtrl = TextEditingController();

  double? _takeProfitCurrentValue;
  double? _stopLossCurrentValue;

  @override
  void initState() {
    super.initState();
    selectedSide = widget.side;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TradeCubit, TradeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          SnackBarService.showSuccess(state.successMessage!);
        }
        if (state.errorMessage != null) {
          SnackBarService.showError(state.errorMessage!);
        }
      },
      child: Scaffold(
        appBar: SimpleAppbar(title: 'New Order'),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SwitchAccountService(accountBuilder: (context, account) {
              return PremiumAppButton(
                text: 'Place Order',
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    context: context,
                    builder: (_) => ReactiveDataService(
                      builder: (context, liveData, calculations) {
                        return OrderConfirmationWidget(
                          symbol: widget.symbol,
                          orderType: _selectedExecution ?? "Market",
                          direction: selectedSide,
                          volume: lotCtrl.text,
                          takeProfit:
                              _tpCtrl.text.isEmpty ? null : _tpCtrl.text,
                          stopLoss: _slCtrl.text.isEmpty ? null : _slCtrl.text,
                          onConfirm: () {
                            final cubit = context.read<TradeCubit>();
                            final jwt = StorageService.getToken();
                            final userId = StorageService.getUser();

                            final tradeAccountId =
                                account.id ?? userId?.id ?? '';

                            final lotValue =
                                double.tryParse(lotCtrl.text.trim()) ?? 0.1;

                            final String executionType =
                                _selectedExecution?.toLowerCase() ?? 'market';
                            final double? limitPrice =
                                double.tryParse(_limitPriceCtrl.text);
                            final double? tpValue =
                                double.tryParse(_tpCtrl.text);
                            final double? slValue =
                                double.tryParse(_slCtrl.text);
                            double avgPrice;
                            if (executionType == 'limit' &&
                                limitPrice != null) {
                              avgPrice = limitPrice;
                            } else {
                              avgPrice = selectedSide == "Buy"
                                  ? calculations.askValue
                                  : calculations.bidValue;
                            }

                            final payload = TradePayload(
                              tradeAccountId: tradeAccountId,
                              symbol: widget.id,
                              lot: lotValue,
                              bs: selectedSide,
                              executionType: executionType,
                              avg: (executionType == 'limit' &&
                                      limitPrice != null)
                                  ? limitPrice
                                  : (selectedSide == 'Buy'
                                      ? calculations.askValue
                                      : calculations.bidValue),
                              target: tpValue,
                              sl: slValue,
                            );

                            debugPrint(
                                '📤 Trade Payload → ${payload.toJson()}');

                            if (jwt != null) {
                              cubit.createTrade(
                                payload: payload,
                                jwt: jwt,
                              );
                            }

                            Navigator.pop(context);
                          },
                        );
                      },
                      symbolName: widget.symbol,
                    ),
                  );
                },
              );
            }),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.symbol,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 20),
                _BuySellTabs(
                  side: widget.side,
                  symbolName: widget.symbol,
                  onChanged: (selected) {
                    setState(() {
                      selectedSide = selected;
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    _buildToggleOption("Market"),
                    const SizedBox(width: 25),
                    _buildToggleOption("Limit"),
                  ],
                ),
                const SizedBox(height: 15),
                if (_selectedExecution == "Limit") ...[
                  _buildBorderedInput(
                      controller: _limitPriceCtrl, hint: "Limit Price"),
                  const SizedBox(height: 15),
                ],
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildBorderedInput(
                          controller: _slCtrl, hint: "Stop Loss"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBorderedInput(
                          controller: _tpCtrl, hint: "Take Profit"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                VolumeSelector(
                  controller: lotCtrl,
                  initialUnit: selectedUnit,
                  onChanged: (volume, unit) {
                    debugPrint("Volume: $volume, Unit: $unit");
                    selectedUnit = unit;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title) {
    bool isSelected = _selectedExecution == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedExecution = isSelected ? null : title;
        });
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBorderedInput(
      {required TextEditingController controller, required String hint}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  void _showOrderTypeSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColor.mediumGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Type",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                ),
                const SizedBox(height: 10),
                _buildTypeRadioTile("Market Execution", setState),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildTypeRadioTile(String value, StateSetter setModalState) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
      value: value,
      groupValue: selectedType,
      onChanged: (val) {
        setModalState(() {
          selectedType = val!;
        });
        setState(() {
          selectedType = val!;
        });
        Navigator.pop(context);
      },
      title: Text(value, style: TextStyle(fontSize: 14)),
      activeColor: AppColor.greenColor,
    );
  }
}

class _BuySellTabs extends StatefulWidget {
  final String side;
  final String symbolName;
  final ValueChanged<String>? onChanged;

  const _BuySellTabs({
    super.key,
    required this.side,
    required this.symbolName,
    this.onChanged,
  });

  @override
  State<_BuySellTabs> createState() => _BuySellTabsState();
}

class _BuySellTabsState extends State<_BuySellTabs> {
  late final ValueNotifier<String> selectedSide;

  @override
  void initState() {
    super.initState();
    selectedSide = ValueNotifier(widget.side);
  }

  void _onTabSelected(String side) {
    if (selectedSide.value == side) return;

    selectedSide.value = side;

    if (widget.onChanged != null) {
      widget.onChanged!(side);
    }
  }

  @override
  void dispose() {
    selectedSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveDataService(
      builder: (context, liveData, calculations) {
        return Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: selectedSide,
                builder: (context, value, _) {
                  return GestureDetector(
                    onTap: () => _onTabSelected("Sell"),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: value == "Sell"
                            ? AppColor.redColor
                            : context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Sell\n${calculations.askValue}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: value == "Sell"
                                ? AppColor.whiteColor
                                : AppColor.greyColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: selectedSide,
                builder: (context, value, _) {
                  return GestureDetector(
                    onTap: () => _onTabSelected("Buy"),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: value == "Buy"
                            ? AppFlavorColor.primary
                            : context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Buy\n${calculations.bidValue}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: value == "Buy"
                                ? AppColor.whiteColor
                                : AppColor.greyColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      symbolName: widget.symbolName,
    );
  }
}
/*
import 'package:exness_clone/constant/trade_data.dart';
import 'package:exness_clone/core/extensions.dart';
import 'package:exness_clone/services/switch_account_service.dart';
import 'package:exness_clone/services/storage_service.dart';
import 'package:exness_clone/utils/common_utils.dart';
import 'package:exness_clone/utils/snack_bar.dart';
import 'package:exness_clone/view/account/buy_sell_trade/model/trade_payload.dart';
import 'package:exness_clone/view/account/trade_screen/widget/order_confirmation.dart';
import 'package:exness_clone/view/account/trade_screen/widget/tp_sl_widget.dart';
import 'package:exness_clone/view/account/trade_screen/widget/volume_selector.dart';
import 'package:exness_clone/view/trade/model/trade_account.dart';
import 'package:exness_clone/widget/button/premium_app_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/reactive_data_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_flavor_color.dart';
import '../../../widget/simple_appbar.dart';
import '../../../widget/slidepage_navigate.dart';
import '../btc_chart/btc_chart_screen.dart';

import '../buy_sell_trade/cubit/trade_cubit.dart';
import '../buy_sell_trade/cubit/trade_state.dart';

class NewOrderScreen extends StatefulWidget {
  final String side;
  final String symbol;
  final String id;
  final String sector;

  const NewOrderScreen(
      {super.key,
      required this.side,
      required this.symbol,
      required this.id,
      required this.sector});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  String selectedType = 'Market Execution';
  String? _selectedExecution = 'Market';
  String selectedUnit = 'USD';
  double sliderValue = 0;
  String selectedSide = 'Buy';
  bool doNotShowAgain = false;
  bool isTakeProfit = false;
  bool isStopLoss = false;
  bool isLimitOrder = false;
  final _limitPriceCtrl = TextEditingController();

  final lotCtrl = TextEditingController(text: '0.1');
  final _tpCtrl = TextEditingController();
  final _slCtrl = TextEditingController();

  double? _takeProfitCurrentValue;
  double? _stopLossCurrentValue;

  @override
  void initState() {
    super.initState();
    selectedSide = widget.side;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TradeCubit, TradeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          SnackBarService.showSuccess(state.successMessage!);
        }
        if (state.errorMessage != null) {
          SnackBarService.showError(state.errorMessage!);
        }
      },
      child: Scaffold(
        appBar: SimpleAppbar(title: 'New Order'),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SwitchAccountService(accountBuilder: (context, account) {
              return PremiumAppButton(
                text: 'Place Order',
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    context: context,
                    builder: (_) => ReactiveDataService(
                      builder: (context, liveData, calculations) {
                        return OrderConfirmationWidget(
                          symbol: widget.symbol,
                          orderType: selectedType,
                          direction: selectedSide,
                          volume: lotCtrl.text,
                          takeProfit: isTakeProfit ? _tpCtrl.text : null,
                          stopLoss: isStopLoss ? _slCtrl.text : null,
                          onConfirm: () {
                            final cubit = context.read<TradeCubit>();
                            final jwt = StorageService.getToken();
                            final userId = StorageService.getUser();

                            final tradeAccountId =
                                account.id ?? userId?.id ?? '';

                            final lotValue =
                                double.tryParse(lotCtrl.text.trim()) ?? 0.1;

                            final String executionType = _selectedExecution?.toLowerCase() ?? 'market';

                            final double avg = executionType == 'limit'
                                ? (double.tryParse(
                                        calculations.askValue.toString()) ??
                                    0.0)
                                : (selectedSide == 'Buy'
                                    ? double.parse(
                                        calculations.askValue.toString())
                                    : double.parse(
                                        calculations.bidValue.toString()));

                            final double? tpValue =
                                isTakeProfit && _tpCtrl.text.isNotEmpty
                                    ? double.tryParse(_tpCtrl.text)
                                    : null;

                            final double? slValue =
                                isStopLoss && _slCtrl.text.isNotEmpty
                                    ? double.tryParse(_slCtrl.text)
                                    : null;

                            final payload = TradePayload(
                              tradeAccountId: tradeAccountId,
                              symbol: widget.id,
                              lot: lotValue,
                              bs: selectedSide,
                              executionType: executionType,
                              avg: (executionType == 'limit' && limitPrice != null)
                                  ? limitPrice
                                  : (selectedSide == 'Buy' ? calculations.askValue : calculations.bidValue),
                              target: tpValue,
                              sl: slValue,
                            );

                            debugPrint(
                                '📤 Trade Payload → ${payload.toJson()}');

                            if (jwt != null) {
                              cubit.createTrade(
                                payload: payload,
                                jwt: jwt,
                              );
                            }

                            Navigator.pop(context);
                          },
                          */
/*onConfirm: () {
                            final cubit = context.read<TradeCubit>();
                            final jwt = StorageService.getToken();
                            final userId = StorageService.getUser();

                            final tradeAccountId =
                                account.id ?? userId?.id ?? '';

                            final lotValue =
                                double.tryParse(lotCtrl.text.trim()) ?? 0.1;

                            final executionType =
                                selectedType == 'Market Execution'
                                    ? 'market'
                                    : 'limit';

                            final double avg = executionType == 'limit'
                                ? (double.tryParse(
                                        calculations.askValue.toString()) ??
                                    0.0)
                                : (selectedSide == 'Buy'
                                    ? double.parse(
                                        calculations.askValue.toString())
                                    : double.parse(
                                        calculations.bidValue.toString()));

                            final double? tpValue =
                                isTakeProfit && _tpCtrl.text.isNotEmpty
                                    ? double.tryParse(_tpCtrl.text)
                                    : null;

                            final double? slValue =
                                isStopLoss && _slCtrl.text.isNotEmpty
                                    ? double.tryParse(_slCtrl.text)
                                    : null;

                            final payload = TradePayload(
                              tradeAccountId: tradeAccountId,
                              symbol: widget.id,
                              lot: lotValue,
                              bs: selectedSide,
                              executionType: executionType,
                              avg: avg,
                              target: tpValue,
                              sl: slValue,
                            );

                            debugPrint(
                                '📤 Trade Payload → ${payload.toJson()}');

                            if (jwt != null) {
                              cubit.createTrade(
                                payload: payload,
                                jwt: jwt,
                              );
                            }

                            Navigator.pop(context);
                          },*/ /*

                        );
                      },
                      symbolName: widget.symbol,
                    ),
                  );
                },
              );
            }),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.symbol,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 20),
                _BuySellTabs(
                  side: widget.side,
                  symbolName: widget.symbol,
                  onChanged: (selected) {
                    setState(() {
                      selectedSide = selected;
                    });
                  },
                ),
                SizedBox(height: 20),
                // GestureDetector(
                //   onTap: () => _showOrderTypeSheet(context),
                //   child: Container(
                //     height: 55,
                //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                //     decoration: BoxDecoration(
                //       color: context.scaffoldBackgroundColor,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Row(
                //           children: [
                //             Text(
                //               "$selectedType ",
                //               style: TextStyle(fontSize: 13),
                //             ),
                //             Icon(
                //               Icons.info_outline,
                //               size: 16,
                //               color: AppColor.greyColor,
                //             ),
                //           ],
                //         ),
                //         Icon(
                //           Icons.keyboard_arrow_down_outlined,
                //           size: 20,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),


                Row(
                  children: [
                    _buildToggleOption("Market"),
                    const SizedBox(width: 25),
                    _buildToggleOption("Limit"),
                  ],
                ),
                const SizedBox(height: 15),

                // 2. LIMIT PRICE (Shown only if Limit is selected)
                if (_selectedExecution == "Limit") ...[
                  _buildBorderedInput(controller: _limitPriceCtrl, hint: "Limit Price"),
                  const SizedBox(height: 15),
                ],
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildBorderedInput(controller: _slCtrl, hint: "Stop Loss"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBorderedInput(controller: _tpCtrl, hint: "Take Profit"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                VolumeSelector(
                  controller: lotCtrl,
                  initialUnit: selectedUnit,
                  onChanged: (volume, unit) {
                    debugPrint("Volume: $volume, Unit: $unit");
                    selectedUnit = unit;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(String title) {
    bool isSelected = _selectedExecution == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggles selection: if already selected, it becomes null (optional)
          _selectedExecution = isSelected ? null : title;
        });
      },
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: isSelected ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBorderedInput({required TextEditingController controller, required String hint}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  void _showOrderTypeSheet(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColor.mediumGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Type",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
                ),
                const SizedBox(height: 10),
                _buildTypeRadioTile("Market Execution", setState),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildTypeRadioTile(String value, StateSetter setModalState) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.zero,
      dense: true,
      controlAffinity: ListTileControlAffinity.trailing,
      value: value,
      groupValue: selectedType,
      onChanged: (val) {
        setModalState(() {
          selectedType = val!;
        });
        setState(() {
          selectedType = val!;
        });
        Navigator.pop(context);
      },
      title: Text(value, style: TextStyle(fontSize: 14)),
      activeColor: AppColor.greenColor,
    );
  }
}

class _BuySellTabs extends StatefulWidget {
  final String side;
  final String symbolName;
  final ValueChanged<String>? onChanged;

  const _BuySellTabs({
    super.key,
    required this.side,
    required this.symbolName,
    this.onChanged,
  });

  @override
  State<_BuySellTabs> createState() => _BuySellTabsState();
}

class _BuySellTabsState extends State<_BuySellTabs> {
  late final ValueNotifier<String> selectedSide;

  @override
  void initState() {
    super.initState();
    selectedSide = ValueNotifier(widget.side);
  }

  void _onTabSelected(String side) {
    if (selectedSide.value == side) return;

    selectedSide.value = side;

    if (widget.onChanged != null) {
      widget.onChanged!(side);
    }
  }

  @override
  void dispose() {
    selectedSide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveDataService(
      builder: (context, liveData, calculations) {
        return Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: selectedSide,
                builder: (context, value, _) {
                  return GestureDetector(
                    onTap: () => _onTabSelected("Sell"),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: value == "Sell"
                            ? AppColor.redColor
                            : context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Sell\n${calculations.askValue}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: value == "Sell"
                                ? AppColor.whiteColor
                                : AppColor.greyColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: selectedSide,
                builder: (context, value, _) {
                  return GestureDetector(
                    onTap: () => _onTabSelected("Buy"),
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: value == "Buy"
                            ? AppFlavorColor.primary
                            : context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Buy\n${calculations.bidValue}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: value == "Buy"
                                ? AppColor.whiteColor
                                : AppColor.greyColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      symbolName: widget.symbolName,
    );
  }
}
*/
