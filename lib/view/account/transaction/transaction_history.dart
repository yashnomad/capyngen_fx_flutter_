import 'package:exness_clone/constant/app_vector.dart';
import 'package:exness_clone/theme/app_flavor_color.dart';
import 'package:exness_clone/widget/message_appbar.dart';
import 'package:exness_clone/widget/simple_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/flavor_config.dart';
import '../../../theme/app_colors.dart';
import 'bloc/transaction_history_bloc.dart';
import 'bloc/transaction_history_event.dart';
import 'bloc/transaction_history_state.dart';
import 'model/transaction_history_models.dart';

class TransactionHistory extends StatefulWidget {
  final String tradeUserId;

  const TransactionHistory({
    super.key,
    required this.tradeUserId,
  });

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  String selectedRange = 'Last 7 days';
  bool isPopupOpen = false;
  bool isFilter = false;
  late ScrollController _scrollController;

  final List<String> ranges = [
    'Last 3 days',
    'Last 7 days',
    'Last 30 days',
    'Last 3 months',
  ];

  String selectedTransactionType = 'All';
  String selectedStatus = 'All';
  String selectedAccount = 'All';

  final transactionTypes = [
    'All',
    'Deposit',
    'Withdrawal',
    'Transfer',
  ];

  final statuses = ['All', 'Processing', 'Done', 'Rejected'];
  final accounts = ['All'];

  bool get isApplyEnabled {
    return selectedTransactionType != 'All' ||
        selectedStatus != 'All' ||
        selectedAccount != 'All';
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    context.read<TransactionHistoryBloc>().add(LoadTransactionHistory());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionHistoryBloc>().add(LoadMoreTransactions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _applyFilters() {
    final filter = TransactionFilter(
      transactionType: selectedTransactionType,
      status: selectedStatus,
      account: selectedAccount,
      dateRange: selectedRange,
    );

    context
        .read<TransactionHistoryBloc>()
        .add(FilterTransactions(filter: filter));
    setState(() {
      isFilter = false;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedTransactionType = 'All';
      selectedStatus = 'All';
      selectedAccount = 'All';
    });

    context.read<TransactionHistoryBloc>().add(ResetFilters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleAppbar(title: 'Transaction History'),
      body: isFilter
          ? filterScreen()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<String>(
                        onOpened: () {
                          setState(() {
                            isPopupOpen = true;
                          });
                        },
                        onCanceled: () {
                          setState(() {
                            isPopupOpen = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        color: AppColor.whiteColor,
                        onSelected: (value) {
                          setState(() {
                            isPopupOpen = false;
                            selectedRange = value;
                          });
                        },
                        itemBuilder: (context) => ranges
                            .map(
                              (range) => PopupMenuItem<String>(
                                value: range,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      range,
                                      style:
                                          TextStyle(color: AppColor.blackColor),
                                    ),
                                    if (selectedRange == range)
                                      Icon(
                                        Icons.check,
                                        size: 18,
                                        color: AppColor.blackColor,
                                      ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        offset: const Offset(0, 40),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF68778D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 12, color: AppColor.whiteColor),
                              const SizedBox(width: 6),
                              Text(
                                selectedRange,
                                style: TextStyle(
                                    color: AppColor.whiteColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                isPopupOpen
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down_sharp,
                                color: AppColor.whiteColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          size: 16,
                          color: AppColor.blackColor,
                        ),
                        label: Text(
                          "Filter",
                          style: TextStyle(
                              fontSize: 12, color: AppColor.blackColor),
                        ),
                        style: OutlinedButton.styleFrom(
                            minimumSize: Size(0, 30),
                            side: BorderSide.none,
                            backgroundColor: Colors.grey.shade50,
                            padding: EdgeInsets.symmetric(horizontal: 10)),
                        onPressed: () {
                          setState(() {
                            isFilter = true;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: BlocBuilder<TransactionHistoryBloc,
                        TransactionHistoryState>(
                      builder: (context, state) {
                        if (state is TransactionHistoryLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is TransactionHistoryError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Error loading transactions',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blackColor,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.greyColor,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context
                                        .read<TransactionHistoryBloc>()
                                        .add(RefreshTransactionHistory());
                                  },
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (state is TransactionHistoryEmpty) {
                          return _buildEmptyState();
                        }

                        if (state is TransactionHistoryLoaded) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<TransactionHistoryBloc>()
                                  .add(RefreshTransactionHistory());
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: state.transactions.length +
                                  (state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= state.transactions.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final transaction = state.transactions[index];
                                return _buildTransactionItem(transaction);
                              },
                            ),
                          );
                        }

                        if (state is TransactionHistoryLoadingMore) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<TransactionHistoryBloc>()
                                  .add(RefreshTransactionHistory());
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: state.currentTransactions.length + 1,
                              itemBuilder: (context, index) {
                                if (index >= state.currentTransactions.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final transaction =
                                    state.currentTransactions[index];
                                return _buildTransactionItem(transaction);
                              },
                            ),
                          );
                        }

                        return _buildEmptyState();
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppVector.history,
            height: 70,
          ),
          const SizedBox(height: 12),
          Text(
            "No transaction matches\nyour filters",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColor.blackColor),
          ),
          const SizedBox(height: 6),
          Text(
            "Try changing your search terms",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColor.greyColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon:
                Icon(CupertinoIcons.clear_circled, color: AppColor.whiteColor),
            label: Text(
              "Reset filters",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppFlavorColor.primary,
              foregroundColor: AppColor.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () {
              _resetFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColor.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction.type),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: AppColor.whiteColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.displayType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.blackColor,
                      ),
                    ),
                    Text(
                      '${"\$"}${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        color:
                            transaction.amount >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.createdAt.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColor.greyColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.displayStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColor.greyColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'crypto_deposit':
        return Colors.green;
      case 'withdraw':
      case 'withdrawal':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      default:
        return AppColor.greyColor;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type.toLowerCase()) {
      case 'crypto_deposit':
        return Icons.arrow_downward;
      case 'withdraw':
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
      case 'pending':
        return Colors.orange;
      case 'done':
      case 'completed':
      case 'success':
        return Colors.green;
      case 'rejected':
      case 'failed':
        return Colors.red;
      default:
        return AppColor.greyColor;
    }
  }

  Widget filterScreen() {
    return Container(
      color: AppColor.whiteColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          color: AppColor.mediumGrey,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColor.whiteColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filters',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColor.blackColor),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: AppColor.blackColor),
                            onPressed: () {
                              setState(() {
                                isFilter = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Transaction types',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.blackColor,
                              fontSize: 16)),
                      const SizedBox(height: 15),
                      buildChips(transactionTypes, selectedTransactionType,
                          (val) {
                        selectedTransactionType = val;
                      }),
                      const SizedBox(height: 30),
                      Text('Status',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.blackColor,
                              fontSize: 16)),
                      const SizedBox(height: 10),
                      buildChips(statuses, selectedStatus, (val) {
                        selectedStatus = val;
                      }),
                      const SizedBox(height: 30),
                      Text('Account',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColor.blackColor,
                              fontSize: 16)),
                      const SizedBox(height: 15),
                      buildChips(accounts, selectedAccount, (val) {
                        selectedAccount = val;
                      }),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                selectedTransactionType = 'All';
                                selectedStatus = 'All';
                                selectedAccount = 'All';
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.shade100),
                              child: Text(
                                'Reset',
                                style: TextStyle(color: AppColor.blackColor),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: isApplyEnabled ? _applyFilters : null,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: isApplyEnabled
                                    ? AppFlavorColor.primary
                                    : AppColor.whiteColor,
                                border: Border.all(
                                    color: isApplyEnabled
                                        ? AppColor.transparent
                                        : AppColor.lightGrey),
                              ),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                    color: isApplyEnabled
                                        ? AppColor.whiteColor
                                        : Colors.grey.shade400,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChips(
      List<String> options, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 15,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () {
            setState(() => onSelect(option));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7891AD) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppColor.whiteColor : AppColor.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../services/switch_account_service.dart';
import '../../../theme/app_colors.dart';
import '../../trade/model/trade_account.dart'; // Ensure correct path for Account model
import 'bloc/transaction_history_bloc.dart';
import 'bloc/transaction_history_event.dart';
import 'bloc/transaction_history_state.dart';
import 'model/transaction_history_models.dart';

class TransactionHistory extends StatefulWidget {
  final String tradeUserId;

  const TransactionHistory({super.key, required this.tradeUserId});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  String selectedStatus = 'All Statuses';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<String> statusOptions = [
    'All Statuses',
    'Success',
    'Pending',
    'Failed',
    'Rejected',
    'Waiting'
  ];

  @override
  void initState() {
    super.initState();
    context.read<TransactionHistoryBloc>().add(LoadTransactionHistory());
  }

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    try {
      DateTime dt = date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('MMM dd, yyyy HH:mm').format(dt);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Deposit History",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. ACCOUNT SELECTOR SERVICE ---
            // This replaces the manual "Account" dropdown with your premium service
            SwitchAccountService(
              accountBuilder: (context, account) {
                return _buildHeaderWithAccount(account);
              },
            ),

            const SizedBox(height: 32),

            // --- 2. FILTER SECTION ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_list_outlined, size: 20),
                      SizedBox(width: 8),
                      Text("Filter Transactions",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 20,
                    children: [
                      // Status Dropdown
                      _buildFilterField("Status", _buildDropdown(selectedStatus, statusOptions, (val) {
                        setState(() => selectedStatus = val!);
                        // Trigger Bloc Filter here if needed
                      })),
                      // Date Picker
                      _buildFilterField("Date", _buildTextField(_dateController, "dd-mm-yyyy", Icons.calendar_today_outlined, isDate: true)),
                      // Search ID
                      _buildFilterField("Search", _buildTextField(_searchController, "Transaction ID...", Icons.search)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. TABLE SECTION ---
            _buildTransactionTable(),
          ],
        ),
      ),
    );
  }

  // Helper to build the header area that shows the currently selected account details
  Widget _buildHeaderWithAccount(Account account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Active Account",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Text("${account.accountId} (${account.currency})",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            // Optional: Show balance or type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(account.accountType!.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: BlocBuilder<TransactionHistoryBloc, TransactionHistoryState>(
        builder: (context, state) {
          if (state is TransactionHistoryLoading) {
            return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
          }

          List<Transaction> transactions = [];
          if (state is TransactionHistoryLoaded) transactions = state.transactions;

          if (transactions.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No transactions found for this account")));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 56,
              dataRowHeight: 70,
              columns: const [
                DataColumn(label: Text('TRANSACTION ID', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('PAYMENT MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
              rows: transactions.map((tx) => DataRow(cells: [
                DataCell(Text(tx.id ?? "-", style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
                DataCell(Text("\$${tx.amount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold))),
                DataCell(const Icon(Icons.circle, size: 8, color: Color(0xFF94A3B8))),
                DataCell(_buildStatusBadge(tx.status)),
                DataCell(Text(_formatDate(tx.createdAt), style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
              ])).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 8),
        SizedBox(width: 220, child: field),
      ],
    );
  }

  Widget _buildDropdown(String value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
      decoration: _inputDecoration(),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isDate = false}) {
    return TextField(
      controller: controller,
      readOnly: isDate,
      onTap: isDate ? () async {
        DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
        if (picked != null) controller.text = DateFormat('dd-MM-yyyy').format(picked);
      } : null,
      decoration: _inputDecoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const Color(0xFFE2E8F0) == null ? const BorderSide(color: Color(0xFFE2E8F0)) : const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  Widget _buildStatusBadge(String status) {
    String label = status.toLowerCase();
    Color bgColor;
    Color textColor;

    if (label == 'waiting') {
      bgColor = const Color(0xFFF1F5F9);
      textColor = const Color(0xFF64748B);
    } else if (label == 'pending') {
      bgColor = const Color(0xFFFEF9C3);
      textColor = const Color(0xFF854D0E);
    } else if (label == 'success') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}*/
