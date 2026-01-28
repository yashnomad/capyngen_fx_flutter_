import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../network/api_service.dart';

class CryptoDepositWebView extends StatefulWidget {
  final String url;
  final String cryptoId;

  const CryptoDepositWebView({super.key, required this.url, required this.cryptoId});

  @override
  State<CryptoDepositWebView> createState() => _CryptoDepositWebViewState();
}

class _CryptoDepositWebViewState extends State<CryptoDepositWebView> {
  late final WebViewController _controller;
  String _status = "pending";
  bool _isPolling = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('🌐 Page started: $url'),
          onPageFinished: (url) => debugPrint('✅ Page finished: $url'),
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));


    // _controller = WebViewController()
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadRequest(Uri.parse(widget.url));

    _startPolling();
  }

  void _startPolling() async {
    while (_isPolling && mounted && _status == "pending") {
      await Future.delayed(const Duration(seconds: 3));

      if (!_isPolling || !mounted) break; // check again after delay

      final res = await ApiService.cryptoPaymentStatus(widget.cryptoId);

      if (!_isPolling || !mounted) break; // check again after API call

      if (res.success && res.data != null) {
        final payment = res.data!['payment'];
        final newStatus = payment['deposit_status'] ?? "pending";

        if (mounted) {
          setState(() => _status = newStatus);
        }

        if (newStatus == "completed") {
          if (mounted) _showBottomSheet("✅ Payment Successful", Colors.green);
          break;
        } else if (newStatus == "failed" || newStatus == "expired" || newStatus == "cancel") {
          if (mounted) _showBottomSheet("❌ Payment Failed", Colors.red);
          break;
        }
      }
    }
  }


  void _showBottomSheet(String message, Color color) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isPolling = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Deposit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _isPolling = false;
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
