import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:path_provider/path_provider.dart';

class CachedWebView extends StatefulWidget {
  const CachedWebView({super.key});

  @override
  _CachedWebViewState createState() => _CachedWebViewState();
}

class _CachedWebViewState extends State<CachedWebView> {
  late InAppWebViewController? _controller;
  final String documentName = 'cached_website.html';
  final String _url ='https://rupeezy.in';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Icon(Icons.arrow_back),
              onPressed: () async {
                if (_controller != null && await _controller!.canGoBack()) {
                  _controller?.goBack();
                } else {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
            ElevatedButton(
              child: const Icon(Icons.arrow_forward),
              onPressed: () {
                _controller?.goForward();
              },
            ),
            ElevatedButton(
              child: const Icon(Icons.refresh),
              onPressed: () {
                _controller?.reload();
              },
            ),
          ],
        ),
        body: FutureBuilder(
          // future: _loadCachedFilePath(),
          future: readHtmlDocument(documentName),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return InAppWebView(
                initialData: InAppWebViewInitialData(
                  data: snapshot.data!,
                  baseUrl: WebUri(_url),
                  mimeType: 'text/html',
                  encoding: 'utf8',
                ),
                // initialUrlRequest: URLRequest(url: WebUri(_url)),
                initialSettings: InAppWebViewSettings(
                  cacheEnabled: true,
                  javaScriptEnabled: true,
                  cacheMode: CacheMode.LOAD_CACHE_ELSE_NETWORK,
                ),

                onWebViewCreated: (webViewController) {
                  _controller = webViewController;
                },
                onLoadStop: (controller, url) async {
                  var rawHtml = await controller.evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);");
                  getAndCacheWebsiteData(url!.path, rawHtml);
                },
              );
            } else {
              return InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(_url)),
                onWebViewCreated: (webViewController) {
                  _controller = webViewController;
                },
                onLoadStop: (controller, url) async {
                  var rawHtml = await controller.evaluateJavascript(
                      source:
                          "new XMLSerializer().serializeToString(document);");
                  getAndCacheWebsiteData(_url, rawHtml);
                },
              );
            }
          },
        ));
  }

  void getAndCacheWebsiteData(String url, String rawHtml) async {
    dom.Document document = parser.parse(rawHtml);
    saveFileToLocal(convertDocumentToByteArray(document), documentName);
  }

  //
  Uint8List convertDocumentToByteArray(dom.Document document) {
    String htmlString = document.outerHtml;
    List<int> utf8Bytes = utf8.encode(htmlString);
    return Uint8List.fromList(utf8Bytes);
  }

  Future<String?> readHtmlDocument(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      final htmlString = await file.readAsString();
      return htmlString;
    } catch (e) {
      print('Error reading HTML document: $e');
      return null;
    }
  }

  Future<String> saveFileToLocal(Uint8List htmlBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(htmlBytes);
    return filePath;
  }
}
