import 'package:flutter/material.dart';

import '../widgets/app_webview.dart';

/// A full-screen page that displays a URL in an [AppWebView].
class WebViewPage extends StatelessWidget {
  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppWebView(
        initialUrl: url,
        loadingMessage: '加载中...',
      ),
    );
  }
}
