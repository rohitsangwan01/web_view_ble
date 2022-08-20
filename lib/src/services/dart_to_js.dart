// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/web_view_ble.dart';

///`To Call Javascript event From Dart`
class DartToJs {
  static DartToJs? _instance;
  DartToJs._();
  static DartToJs get to => _instance ??= DartToJs._();

  /// Initialize DartToJs Controller
  late InAppWebViewController controller;

  /// To update Characteristics Value
  Future<void> updateCharacteristicsData(
    String deviceId,
    String cname,
    String d64,
  ) async {
    try {
      Map<String, dynamic> data = {
        "deviceId": deviceId,
        "cname": cname,
        "d64": d64,
      };
      await dispatchJsEvent(event: JsEvents.characteristicsEvent, data: data);
    } catch (e) {
      print(e);
    }
  }

  // To Update connection Method in JavaScript
  Future<void> dispatchJsEvent({
    required String event,
    required Map<String, dynamic> data,
  }) async {
    try {
      String jsonData = jsonEncode(data);
      var response = await controller.callAsyncJavaScript(
        functionBody: """
            const event = new CustomEvent("$event", {
              detail: $jsonData
            });
            window.dispatchEvent(event);
          """,
      );

      if (response?.error != null) {
        logError(response?.error ?? "");
      }
    } catch (e) {
      logError(e.toString());
    }
  }
}

class JsEvents {
  static String connectionEvent = 'flutterConnectionEventListener';
  static String characteristicsEvent = 'flutterCharacteristicsEventListener';
}
