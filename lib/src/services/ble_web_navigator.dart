import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:web_view_ble/src/models/ble_scan_filter.dart';
import 'package:web_view_ble/src/models/web_ble_device.dart';
import 'package:web_view_ble/src/services/ble_manager.dart';
import 'package:web_view_ble/src/services/logger.dart';

class BleWebNavigator {
  static const _requestDevice = 'requestDevice';
  static const _getAvailability = 'getAvailability';
  static const _readCharacteristicValue = 'device:readCharacteristicValue';
  static const _writeCharacteristicValue = 'device:writeCharacteristicValue';
  static const _startNotifications = 'device:startNotifications';
  static const _stopNotifications = 'device:stopNotifications';
  static const _connectGATT = 'device:connectGATT';
  static const _disconnectGATT = 'device:disconnectGATT';
  static const _getPrimaryServices = 'device:getPrimaryServices';
  static const _getCharacteristics = 'device:getCharacteristics';
  static const _getCharacteristic = 'device:getCharacteristic';

  /// Register all Communicators with web view
  static void registerNavigatorBluetooth({
    required InAppWebViewController controller,
    required BleManager bleService,
    required BuildContext context,
  }) {
    // To request device
    controller.addJavaScriptHandler(
      handlerName: _requestDevice,
      callback: (args) async {
        BleScanFilter scanFilter = BleScanFilter();
        scanFilter.fromJson(args.data);
        WebBleDevice? device = await bleService.getBleDevice(
          context: context,
          bleScanFilter: scanFilter,
        );
        return device?.toJson() ?? {"error": "No Device Selected "};
      },
    );

    // To get radio availability
    controller.addJavaScriptHandler(
      handlerName: _getAvailability,
      callback: (args) => bleService.getAvailability(),
    );

    // To read characteristic
    controller.addJavaScriptHandler(
        handlerName: _readCharacteristicValue,
        callback: (args) async {
          String? deviceID = args.deviceId;
          String? characteristicUUID = args.characteristicUUID;
          String? serviceUUID = args.serviceUUID;
          if (deviceID == null ||
              characteristicUUID == null ||
              serviceUUID == null) {
            return {"error": "InvalidArgs"};
          }
          return await bleService.readCharacteristics(
            characteristicUUID: characteristicUUID,
            serviceUUID: serviceUUID,
            deviceID: deviceID,
          );
        });

    //To write characteristic
    controller.addJavaScriptHandler(
        handlerName: _writeCharacteristicValue,
        callback: (args) async {
          logWarning(args.toString());
          String? deviceID = args.deviceId;
          String? characteristicUUID = args.characteristicUUID;
          String? serviceUUID = args.serviceUUID;
          String? value = args.value;
          bool writeWithResponse = true;
          if (deviceID == null ||
              characteristicUUID == null ||
              serviceUUID == null ||
              value == null) {
            return {"error": "InvalidArgs"};
          }
          await bleService.writeCharacteristics(
            characteristicUUID: characteristicUUID,
            serviceUUID: serviceUUID,
            deviceID: deviceID,
            value: value,
            writeWithResponse: writeWithResponse,
          );
          return {};
        });

    //To Start Notification
    controller.addJavaScriptHandler(
        handlerName: _startNotifications,
        callback: (args) async {
          String? deviceID = args.deviceId;
          String? characteristicUUID = args.characteristicUUID;
          String? serviceUUID = args.serviceUUID;
          if (deviceID == null ||
              characteristicUUID == null ||
              serviceUUID == null) {
            return {"error": "InvalidArgs"};
          }
          await bleService.subscribeCharacteristics(
            characteristicUUID: characteristicUUID,
            serviceUUID: serviceUUID,
            deviceID: deviceID,
          );
          return {};
        });

    //To Stop Notification
    controller.addJavaScriptHandler(
        handlerName: _stopNotifications,
        callback: (args) async {
          String? deviceID = args.deviceId;
          String? characteristicUUID = args.characteristicUUID;
          String? serviceUUID = args.serviceUUID;
          if (deviceID == null ||
              characteristicUUID == null ||
              serviceUUID == null) {
            return {"error": "InvalidArgs"};
          }
          await bleService.unSubscribeCharacteristics(
            characteristicUUID: characteristicUUID,
            serviceUUID: serviceUUID,
            deviceID: deviceID,
          );
          return {};
        });

    // To connect
    controller.addJavaScriptHandler(
        handlerName: _connectGATT,
        callback: (args) async {
          String? deviceID = args.deviceId;
          if (deviceID == null) return {"error": "InvalidArgs"};
          return await bleService.connect(deviceId: deviceID);
        });

    // To disconnect
    controller.addJavaScriptHandler(
        handlerName: _disconnectGATT,
        callback: (args) async {
          String? deviceID = args.deviceId;
          if (deviceID == null) return {"error": "InvalidArgs"};
          await bleService.disconnect(deviceID);
          return true;
        });

    // To Get Primary Services
    controller.addJavaScriptHandler(
        handlerName: _getPrimaryServices,
        callback: (args) async {
          logInfo(args.toString());
          String? deviceID = args.deviceId;
          String? serviceUUID = args.serviceUUID;
          if (deviceID == null) return {"error": "InvalidArgs"};
          var servicesList = await bleService.discoverServices(deviceID);
          if (serviceUUID == null) return servicesList;
          return servicesList.where((e) => e == serviceUUID).toList();
        });

    // To Get characteristic list
    controller.addJavaScriptHandler(
        handlerName: _getCharacteristics,
        callback: (args) async {
          logInfo(args.toString());
          String? deviceID = args.deviceId;
          String? serviceUUID = args.serviceUUID;
          if (deviceID == null || serviceUUID == null) {
            return {"error": "InvalidArgs"};
          }
          return await bleService.getCharacteristics(
            deviceID: deviceID,
            serviceUUID: serviceUUID,
          );
        });

    // To Get characteristic
    controller.addJavaScriptHandler(
      handlerName: _getCharacteristic,
      callback: (args) async {
        logInfo(args.toString());
        String? deviceID = args.deviceId;
        String? characteristicUUID = args.characteristicUUID;
        String? serviceUUID = args.serviceUUID;
        if (deviceID == null ||
            characteristicUUID == null ||
            serviceUUID == null) {
          return {"error": "InvalidArgs"};
        }
        return await bleService.getCharacteristic(
          characteristicUUID: characteristicUUID,
          serviceUUID: serviceUUID,
          deviceID: deviceID,
        );
      },
    );
  }

  static void deRegister(InAppWebViewController controller) {
    controller.removeJavaScriptHandler(handlerName: _requestDevice);
    controller.removeJavaScriptHandler(handlerName: _getAvailability);
    controller.removeJavaScriptHandler(handlerName: _readCharacteristicValue);
    controller.removeJavaScriptHandler(handlerName: _writeCharacteristicValue);
    controller.removeJavaScriptHandler(handlerName: _startNotifications);
    controller.removeJavaScriptHandler(handlerName: _stopNotifications);
    controller.removeJavaScriptHandler(handlerName: _connectGATT);
    controller.removeJavaScriptHandler(handlerName: _disconnectGATT);
    controller.removeJavaScriptHandler(handlerName: _getPrimaryServices);
    controller.removeJavaScriptHandler(handlerName: _getCharacteristics);
  }
}

extension _ArgExtension on List<dynamic> {
  Map<String, dynamic>? get data {
    if (isEmpty) return null;
    return first?['data'];
  }

  String? get deviceId {
    return data?['deviceId'];
  }

  String? get characteristicUUID {
    return data?['characteristicUUID'];
  }

  String? get serviceUUID {
    return data?['serviceUUID'];
  }

  String? get value {
    return data?['value'];
  }
}
