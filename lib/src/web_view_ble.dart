import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/src/services/ble_service.dart';
import 'package:web_view_ble/src/services/dart_to_js.dart';
import 'package:web_view_ble/web_view_ble.dart';
import 'js_handler/js_handler.dart';

class WebViewBle {
  static BuildContext? context;
  static InAppWebViewController? controller;
  WebViewBle();

  static bool _isInitialized = false;

  ///call `init` in `OnLoad Callback` of WebView
  static init({
    required BuildContext context,
    required InAppWebViewController controller,
  }) {
    _addJsHandlers(controller);
    _insertBleJs(controller);
    _initDartToJs(controller);
    _initializeBleService(context);
  }

  

  // Initialize BleService only Once
  static _initializeBleService(BuildContext context) {
    if (_isInitialized) return;
    logInfo('Bluetooth Services Initialized');
    _isInitialized = true;
    BleService.to.init(context);
  }

  ///`Add All Handlers for JS Communication`
  static Future<void> _addJsHandlers(InAppWebViewController controller) =>
      JsHandler(webViewController: controller).addHandlers();

  ///`Insert JS Files`
  static Future<void> _insertBleJs(InAppWebViewController controller) async {
    for (var jsFile in _jsFiles) {
      await controller.injectJavascriptFileFromAsset(
          assetFilePath: "packages/web_view_ble/assets/$jsFile.js");
    }
  }

  static _initDartToJs(InAppWebViewController controller) =>
      DartToJs.to.controller = controller;

  ///`All Javascript Files`
  static final _jsFiles = [
    "stringview",
    "WBUtils",
    "WBEventTarget",
    "WBBluetoothUUID",
    "WBDevice",
    "WBBluetoothRemoteGATTServer",
    "WBBluetoothRemoteGATTService",
    "WBBluetoothRemoteGATTCharacteristic",
    "WBPolyfill"
  ];
}
