import 'dart:io';
import 'package:finance_plan/constants/color_constant.dart';
import 'package:finance_plan/constants/style_constant.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DetailBeritaWebview extends StatefulWidget {
  final String? link;
  DetailBeritaWebview({Key? key, this.link}) : super(key: key);
  @override
  DetailBeritaWebviewState createState() => DetailBeritaWebviewState();
}

class DetailBeritaWebviewState extends State<DetailBeritaWebview> {
  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mPrimaryColor,
        title: Text(
          'Detail Berita',
          style: mCardTitleStyle,
        ),
      ),
      body: WebView(
        initialUrl: widget.link,
      ),
    );
  }
}
