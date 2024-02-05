import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final keepAlive = InAppWebViewKeepAlive();

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () async {
                if (_controller != null && await _controller!.canGoBack()) {
                  _controller?.goBack();
                } else {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.circle_outlined, color: Colors.black)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.square_outlined, color: Colors.black)),
        ],
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: InAppWebView(
              keepAlive: keepAlive,
              initialUrlRequest: URLRequest(url: WebUri("https://rupeezy.in")),
              initialSettings: InAppWebViewSettings(),
              onWebViewCreated: (webViewController) {
                _controller = webViewController;
              }),
        )
      ]),
    );
  }
}
