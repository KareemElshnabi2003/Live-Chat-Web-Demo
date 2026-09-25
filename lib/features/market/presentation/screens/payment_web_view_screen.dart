// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:live_chat/core/routing/routes.dart';
import 'package:live_chat/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String iframeUrl;
  const PaymentWebView({super.key, required this.iframeUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  WebViewController? _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      isLoading = false;
      // On web, launch the payment URL directly in browser
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchPaymentWeb();
      });
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFFFFF))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) setState(() => isLoading = true);
            },
            onPageFinished: (url) {
              if (mounted) setState(() => isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint("WebView error: ${error.description}");
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.iframeUrl));
    }
  }

  Future<void> _launchPaymentWeb() async {
    final uri = Uri.parse(widget.iframeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        context.go(Routes.homeScreen);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.go(Routes.homeScreen);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(S.of(context).purchase),
          centerTitle: true,
        ),
        body: kIsWeb
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 64, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).purchase,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _launchPaymentWeb,
                        icon: const Icon(Icons.open_in_new),
                        label: Text(S.of(context).purchase),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  if (_controller != null) WebViewWidget(controller: _controller!),
                  if (isLoading) const Center(child: CircularProgressIndicator()),
                ],
              ),
      ),
    );
  }
}
