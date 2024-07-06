import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/src/services/logger.dart';

///`To Call Javascript event From Dart`
class DartToJs {
  static InAppWebViewController? controller;

  static const String _connectionEvent = 'flutterConnectionEventListener';
  static const String _characteristicsEvent =
      'flutterCharacteristicsEventListener';
  static const String _availabilityEvent =
      'flutterAvailabilityChangeEventListener';

  /// To update Characteristics Value
  static Future<void> updateCharacteristicsData({
    required String deviceId,
    required String cname,
    required String d64,
  }) async {
    await _dispatchJsEvent(
      event: _characteristicsEvent,
      data: {
        "deviceId": deviceId,
        "cname": cname,
        "d64": d64,
      },
    );
  }

  /// To update Availability Status
  static Future<void> updateAvailabilityStatus({
    required bool isAvailable,
  }) async {
    await _dispatchJsEvent(
      event: _availabilityEvent,
      data: {
        "isAvailable": isAvailable,
      },
    );
  }

  /// To update Connection Status
  static Future<void> updateConnectionStatus({
    required String deviceId,
    required bool isConnected,
  }) async {
    await _dispatchJsEvent(
      event: _connectionEvent,
      data: {
        "deviceId": deviceId,
        "state": isConnected,
      },
    );
  }

  // To Update connection Method in JavaScript
  static Future<void> _dispatchJsEvent({
    required String event,
    required Map<String, dynamic> data,
  }) async {
    try {
      String jsonData = jsonEncode(data);
      var response = await controller?.callAsyncJavaScript(
        functionBody: """
            const event = new CustomEvent("$event", {
              detail: $jsonData
            });
            window.dispatchEvent(event);
          """,
      );
      String? error = response?.error;
      if (error != null) throw Exception(error);
    } catch (e) {
      logError(e.toString());
    }
  }
}
