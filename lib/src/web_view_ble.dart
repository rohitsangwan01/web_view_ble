// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/src/services/ble_service.dart';
import 'package:web_view_ble/src/services/dart_to_js.dart';
import 'js_handler/js_handler.dart';

class WebViewBle {
  BuildContext context;
  InAppWebViewController controller;
  WebViewBle({required this.controller, required this.context});

  ///call `init` in `OnWebViewCreated`
  init() {
    _addJsHandlers();
    _insertBleJs();
    _initDartToJs(controller);
    BleService.to.init(context);
  }

  ///`Add All Handlers for JS Communication`
  _addJsHandlers() async {
    JsHandler(webViewController: controller).addHandlers();
  }

  ///`Insert JS Files`
  _insertBleJs() {
    for (var jsFile in _jsFiles) {
      controller.injectJavascriptFileFromAsset(
          assetFilePath: "packages/web_view_ble/assets/$jsFile.js");
    }
    print("Js Inserted");
  }

  _initDartToJs(controller) {
    DartToJs.to.controller = controller;
  }

  ///`All Javascript Files`
  final _jsFiles = [
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
