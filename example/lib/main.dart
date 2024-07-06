// ignore_for_file: avoid_print

import 'package:example/permission_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/web_view_ble.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "WebViewBle",
      home: WebsiteView(),
    ),
  );
}

class WebsiteView extends StatefulWidget {
  const WebsiteView({Key? key}) : super(key: key);

  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  var url = 'https://googlechrome.github.io/samples/web-bluetooth/index.html';
  // var url = 'https://jeroen1602.github.io/flutter_web_bluetooth/#/';

  final urlController = TextEditingController();
  InAppWebViewController? webViewController;
  bool canGoBack = false;

  @override
  void initState() {
    validatePermissions();
    super.initState();
  }

  Future<void> onLoadStop(controller, context) async {
    url = url.toString();
    urlController.text = url;
    WebViewBle.setup(
      controller: controller,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("WebViewBle"),
          centerTitle: true,
          leading: canGoBack
              ? IconButton(
                  onPressed: () {
                    webViewController?.goBack();
                  },
                  icon: const Icon(Icons.arrow_back_ios))
              : const SizedBox(),
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              Uri url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("https://www.google.com/search?q=$value");
              }
              webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri.uri(url)));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(url)),
                  onLoadStop: (ctrl, url) async {
                    onLoadStop(ctrl, context);
                    webViewController = ctrl;
                    canGoBack = await ctrl.canGoBack();
                    setState(() {});
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(
                      "ConsoleMessage : ${consoleMessage.messageLevel.toString()} :  ${consoleMessage.message}",
                    );
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
