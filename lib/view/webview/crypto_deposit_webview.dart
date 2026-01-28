/*
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CryptoDepositWebView extends StatefulWidget {
  final String url;
  const CryptoDepositWebView({super.key, required this.url});

  @override
  State<CryptoDepositWebView> createState() => _CryptoDepositWebViewState();
}

class _CryptoDepositWebViewState extends State<CryptoDepositWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Deposit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
*/
