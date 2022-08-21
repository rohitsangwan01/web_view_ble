# WebView Ble

[![web_view_ble version](https://img.shields.io/pub/v/web_view_ble?label=web_view_ble)](https://pub.dev/packages/web_view_ble)

Flutter library To add Bluetooth Low Energy Support in WebView Flutter

## Getting Started

Using [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for WebView
and [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble) for bluetooth

Import these Libraries in your pubspec.yaml

```dart
flutter_inappwebview: ^5.4.3+7
web_view_ble: 0.0.4
```

Add WebView in your Project , Check flutter_inappwebview [docs](https://inappwebview.dev/docs/) for setting up WebView

And check [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble) docs for adding bluetooth related settings in your native projects

## Usage

in your `onLoadStop` callback of flutter_inappwebview , add this method

```dart
void onLoadStop(InAppWebViewController controller,BuildContext context) async {
    WebViewBle.init(controller: controller, context: context);
}
```

Checkout [/example](https://github.com/rohitsangwan01/web_view_ble/tree/main/example) for more details

## Features

The web_view_ble lib supports the following bluetooth Api's:

- Request Device (Filters : ServiceId , name , namePrefix)
- Connect
- Disconnect
- Discover services
- Discover characteristics
- Read / write a characteristic
- Subscribe / unsubscribe to a characteristic

## Resources

Thanks to [WebBle](https://github.com/daphtdazz/WebBLE) for Ble javascript Polyfill

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
