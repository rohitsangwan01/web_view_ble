# WebView Ble

[![web_view_ble version](https://img.shields.io/pub/v/web_view_ble?label=web_view_ble)](https://pub.dev/packages/web_view_ble)

Flutter library To add Bluetooth Low Energy Support in WebView Flutter

## Getting Started

Using [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview) for WebView, Make sure to Check their [docs](https://inappwebview.dev/docs/) for setting up WebView

And [universal_ble](https://pub.dev/packages/universal_ble) for bluetooth, check [docs](https://pub.dev/packages/universal_ble#platform-specific-setup) for platform specific setup

## Usage

Make sure to ask `bluetooth` permission first, check `universal_ble` for more details

In your `onLoadStop` callback of `flutter_inappwebview` , add this method

```dart
WebViewBle.setup(controller: controller, context: context);
```

Dispose when not needed anymore

```dart
WebViewBle.dispose();
```

Checkout [/example](https://github.com/rohitsangwan01/web_view_ble/tree/main/example) for more details

## Features

The web_view_ble lib supports the following bluetooth Api's:

- Request Device (Filters : ServiceId , name , namePrefix, manufacturerData)
- Connect
- Disconnect
- Discover services
- Discover characteristics
- Read / write a characteristic
- Subscribe / unsubscribe to a characteristic

## Attribution

Thanks to [WebBle](https://github.com/daphtdazz/WebBLE) for Ble javascript Polyfill, This project is licensed under the Apache Version 2.0 License as per the [LICENSE](LICENSE) file.

## Additional information

This is Just The Initial Version feel free to Contribute or Report any Bug!
