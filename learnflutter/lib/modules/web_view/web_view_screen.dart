import 'package:flutter/material.dart';
import 'package:learnflutter/component/base_loading_screen/base_loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  @override
  void initState() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://agents.fpt.ai/live-chat/chat?tenant_id=01JNJVV5TX8QX5R521SDAA8SAW&bot_code=01JWZPK62975PSACJ3GTDPADCS'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoading(
      child: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}
