import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_webview.dart';

class Enable65Page extends StatefulWidget {
  const Enable65Page({super.key});

  @override
  State<Enable65Page> createState() => _Enable65PageState();
}

class _Enable65PageState extends State<Enable65Page> {
  static const List<String> _encryptedUrls = [
    'Mi4uKilgdXVibWhoPml0LTs0LT80MHQ5NTc=',
    'Mi4uKilgdXVibWhoPml0Pj0yPykydDk1Nw==',
    'Mi4uKilgdXVibWhoPml0MjszKzMwInQ5NTc=',
    'Mi4uKilgdXVibWhoPml0KjIoKjItdDk1Nw==',
    'Mi4uKilgdXVibWhoPml0Kzk9OTAidDk1Nw==',
    'Mi4uKilgdXUzNSl0LSIiIC4vdDk1Nw==',
  ];

  static const int _k = 0x5A;

  late List<int> _shuffledIndices;
  int _currentIndex = 0;
  Key _webViewKey = UniqueKey();
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();
    _shuffledIndices = List.generate(_encryptedUrls.length, (i) => i);
    _shuffledIndices.shuffle(Random());
  }

  static String _decrypt(String encrypted) {
    final decoded = base64.decode(encrypted);
    final decrypted = decoded.map((b) => b ^ _k).toList();
    return utf8.decode(decrypted);
  }

  String _getCurrentUrl() {
    final index = _shuffledIndices[_currentIndex];
    return _decrypt(_encryptedUrls[index]);
  }

  void _tryNextUrl() {
    if (_isSwitching) return;
    _isSwitching = true;

    if (_currentIndex < _shuffledIndices.length - 1) {
      setState(() {
        _currentIndex++;
        _webViewKey = UniqueKey();
      });
    } else {
      setState(() {
        _shuffledIndices.shuffle(Random());
        _currentIndex = 0;
        _webViewKey = UniqueKey();
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _isSwitching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AppWebView(
          key: _webViewKey,
          initialUrl: _getCurrentUrl(),
          onLoadError: _tryNextUrl,
        ),
      ),
    );
  }
}
