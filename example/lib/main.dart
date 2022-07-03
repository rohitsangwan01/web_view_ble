import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_view_ble/web_view_ble.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flowser",
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
  final urlController = TextEditingController();

  InAppWebViewController? webViewController;

  @override
  void initState() {
    askBlePermission();
    super.initState();
  }

  askBlePermission() async {
    var status = await Permission.bluetooth.status;
    if (status.isDenied) {
      Permission.bluetooth.request();
    }
  }

  onLoadStop(controller, context) async {
    url = url.toString();
    urlController.text = this.url;
    WebViewBle(controller: controller, context: context).init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Flowser"),
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.url,
            onSubmitted: (value) {
              var url = Uri.parse(value);
              if (url.scheme.isEmpty) {
                url = Uri.parse("https://www.google.com/search?q=" + value);
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  onLoadStop: (cntrl, url) {
                    onLoadStop(cntrl, context);
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print(
                        "ConsoleMessage : ${consoleMessage.messageLevel.toString()} :  ${consoleMessage.message} ");
                  },
                ),
              ],
            ),
          ),
        ])));
  }
}
