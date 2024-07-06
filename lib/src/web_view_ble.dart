import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/src/services/ble_web_navigator.dart';
import 'package:web_view_ble/src/services/ble_manager.dart';
import 'package:web_view_ble/src/services/dart_to_js.dart';

/// WebViewBle to interact with bluetooth on WebView
class WebViewBle {
  static BleManager? _bleService;

  /// Call `setup` in `OnLoad` Callback of WebView
  static Future<void> setup({
    required BuildContext context,
    required InAppWebViewController controller,
  }) async {
    _bleService ??= BleManager();
    DartToJs.controller = controller;
    BleWebNavigator.registerNavigatorBluetooth(
      context: context,
      controller: controller,
      bleService: _bleService!,
    );
    await _injectPolyfill(controller);
  }

  /// Dispose when not required
  static void dispose({InAppWebViewController? controller}) {
    _bleService?.dispose();
    _bleService = null;
    DartToJs.controller = null;
    if (controller != null) {
      BleWebNavigator.deRegister(controller);
    }
  }

  /// Inject all BlePolyfill files to WebPage
  static Future<void> _injectPolyfill(InAppWebViewController controller) async {
    for (String jsFile in [
      "stringview",
      "WBUtils",
      "WBEventTarget",
      "WBBluetoothUUID",
      "WBDevice",
      "WBBluetoothRemoteGATTServer",
      "WBBluetoothRemoteGATTService",
      "WBBluetoothRemoteGATTCharacteristic",
      "WBPolyfill"
    ]) {
      await controller.injectJavascriptFileFromAsset(
        assetFilePath: "packages/web_view_ble/web_ble/$jsFile.js",
      );
    }
  }
}
