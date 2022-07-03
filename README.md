# web_view_ble

web_view_ble To add Bluetooth Low Energy Support in WebView Flutter

## Getting Started

Currently using [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for WebView
and [quick_blue](https://pub.dev/packages/quick_blue) for bluetooth

Import these Libraries in your pubspec.yaml

```dart
flutter_inappwebview: ^5.4.3+7
web_view_ble: 0.0.1
```

add WebView in your Project , Check flutter_inappwebview [docs](https://inappwebview.dev/docs/) for setting WebView
and check [quick_blue](https://pub.dev/packages/quick_blue) docs for adding bluetooth related settings in your native folders

then inside `onLoadStop` callback of WebView , call this library like this

```dart
void onLoadStop(InAppWebViewController controller,BuildContext context) async {
    WebViewBle(controller: controller, context: context).init();
}
```

and that's it ,WebBluetooth support will be added to your webview ,
Checkout Example for more details

Currently projet is in Early stage ,many features are pending to implement yet and Apis might change later

## Supported Api's :

`Request Device`

`Connect`

`Disconnect`

`Read Characteristics`

`Write Characteristics`

## TODO :

`getCharacteristics List`

`Subscribe/Unsubscribe to Characteristics`

`Update Device Connection State Event`

## Resources

Thanks to [WebBle](https://github.com/daphtdazz/WebBLE) for Ble javascript Polyfill

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
