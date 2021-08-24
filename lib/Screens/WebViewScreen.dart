import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants.dart';

class WebViewScreen extends StatefulWidget {
  String url;

  WebViewScreen(this.url);

  @override
  WebViewScreenState createState() => WebViewScreenState(url);
}

class WebViewScreenState extends State<WebViewScreen> {
  String url;

  WebViewScreenState(this.url);

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(PROJECT_NAME),
        backgroundColor: HexColor('#dc3f4d'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: HexColor('#ffffff'),
        child: SafeArea(
          left: false,
          right: false,
          bottom: true,
          child: Container(
            child: WebView(
              initialUrl: url,
            ),
          ),
        ),
      ),
    );
  }
}
