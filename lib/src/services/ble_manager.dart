import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:web_view_ble/src/models/ble_scan_filter.dart';
import 'package:web_view_ble/src/models/web_ble_device.dart';
import 'package:web_view_ble/src/services/dart_to_js.dart';
import 'package:web_view_ble/src/widgets/scan_dialog.dart';
import 'package:web_view_ble/src/services/logger.dart';

/// Manage all ble related tasks
class BleManager {
  final Map<String, List<BleService>> _servicesCache = {};
  StreamController<(String deviceId, bool isConnected)>?
      _connectionStreamController;

  BleManager() {
    _connectionStreamController = StreamController.broadcast();

    UniversalBle.onAvailabilityChange = (AvailabilityState state) {
      if (state == AvailabilityState.poweredOn ||
          state == AvailabilityState.poweredOff) {
        DartToJs.updateAvailabilityStatus(
          isAvailable: state == AvailabilityState.poweredOn,
        );
      }
    };

    UniversalBle.onConnectionChange = (String deviceId, bool isConnected) {
      _connectionStreamController?.add((deviceId, isConnected));
      DartToJs.updateConnectionStatus(
        deviceId: deviceId,
        isConnected: isConnected,
      );
      if (!isConnected) {
        _servicesCache.remove(deviceId);
      }
    };

    UniversalBle.onValueChange =
        (String deviceId, String characteristicId, Uint8List value) {
      DartToJs.updateCharacteristicsData(
        deviceId: deviceId,
        cname: characteristicId,
        d64: base64.encode(value),
      );
    };
  }

  void dispose() {
    _connectionStreamController?.close();
    _connectionStreamController = null;

    UniversalBle.onScanResult = null;
    UniversalBle.onAvailabilityChange = null;
    UniversalBle.onConnectionChange = null;
    UniversalBle.onValueChange = null;
  }

  Future<bool> getAvailability() async =>
      await UniversalBle.getBluetoothAvailabilityState() ==
      AvailabilityState.poweredOn;

  Future<WebBleDevice?> getBleDevice({
    required BuildContext context,
    required BleScanFilter bleScanFilter,
  }) async {
    return await getBleDeviceFromDialog(
      context: context,
      bleScanFilter: bleScanFilter,
    );
  }

  Future<List<Map<String, dynamic>>?> getCharacteristics({
    required String serviceUUID,
    required String deviceID,
  }) async {
    List<BleService> services = await _getServices(deviceID);
    if (services.isEmpty) return null;
    BleService? service = services.firstWhereOrNull(
      (element) => element.uuid == serviceUUID,
    );
    return service?.characteristics.map((e) => e.toJson()).toList();
  }

  Future<Map<String, dynamic>?> getCharacteristic({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) async {
    List<BleService> services = await _getServices(deviceID);
    BleService? service = services.firstWhereOrNull(
      (service) => service.uuid == serviceUUID,
    );
    return service?.characteristics
        .firstWhereOrNull((char) => char.uuid == characteristicUUID)
        ?.toJson();
  }

  Future<bool> connect({
    required String deviceId,
    Duration? timeout,
  }) async {
    Completer<bool>? completer;
    Timer? timer;
    StreamSubscription? connectionStreamSubscription;

    try {
      BleConnectionState connectionState =
          await UniversalBle.getConnectionState(deviceId);
      if (connectionState == BleConnectionState.connected) {
        return true;
      }

      completer = Completer();

      if (timeout != null) {
        timer = Timer(timeout, () {
          connectionStreamSubscription?.cancel();
          if (completer?.isCompleted == false) {
            completer?.complete(false);
          }
        });
      }

      connectionStreamSubscription = _connectionStreamController?.stream
          .where((e) => e.$1 == deviceId)
          .map((e) => e.$2)
          .listen((bool isConnected) {
        timer?.cancel();
        connectionStreamSubscription?.cancel();
        if (completer?.isCompleted == false) {
          completer?.complete(isConnected);
        }
      });

      await UniversalBle.connect(deviceId);
      return await completer.future;
    } catch (e) {
      logError(e);
      timer?.cancel();
      connectionStreamSubscription?.cancel();
      completer?.complete(false);
      disconnect(deviceId);
      return false;
    }
  }

  Future<void> disconnect(deviceId) => UniversalBle.disconnect(deviceId);

  Future<List<String>> discoverServices(deviceId) async {
    List<BleService> services = await _getServices(deviceId);
    return services.map((e) => e.uuid.toString()).toList();
  }

  Future<void> writeCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
    required String value,
    required bool writeWithResponse,
  }) async {
    return UniversalBle.writeValue(
      deviceID,
      serviceUUID,
      characteristicUUID,
      base64.decode(value),
      writeWithResponse
          ? BleOutputProperty.withResponse
          : BleOutputProperty.withoutResponse,
    );
  }

  // Convert bytes to base64 String
  Future<String> readCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) async {
    Uint8List data = await UniversalBle.readValue(
      deviceID,
      serviceUUID,
      characteristicUUID,
    );
    return base64.encode(data);
  }

  Future<void> subscribeCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) async {
    Map<String, dynamic>? char = await getCharacteristic(
      characteristicUUID: characteristicUUID,
      serviceUUID: serviceUUID,
      deviceID: deviceID,
    );
    bool? notify = char?['properties']?['notify'];
    // Todo check if notify or indicate
    await UniversalBle.setNotifiable(
      deviceID,
      serviceUUID,
      characteristicUUID,
      notify == true
          ? BleInputProperty.notification
          : BleInputProperty.indication,
    );
  }

  Future<void> unSubscribeCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) async {
    await UniversalBle.setNotifiable(
      deviceID,
      serviceUUID,
      characteristicUUID,
      BleInputProperty.disabled,
    );
  }

  Future<List<BleService>> _getServices(String deviceId) async {
    return _servicesCache[deviceId] ??
        await UniversalBle.discoverServices(deviceId);
  }
}

extension _IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension _CharExtension on BleCharacteristic {
  Map<String, dynamic> toJson() {
    return {
      "uuid": uuid,
      "properties": {
        "read": properties.contains(CharacteristicProperty.read),
        "write": properties.contains(CharacteristicProperty.write),
        "writeWithoutResponse":
            properties.contains(CharacteristicProperty.writeWithoutResponse),
        "notify": properties.contains(CharacteristicProperty.notify),
        "broadcast": properties.contains(CharacteristicProperty.broadcast),
        "indicate": properties.contains(CharacteristicProperty.indicate),
        "authenticatedSignedWrites": properties
            .contains(CharacteristicProperty.authenticatedSignedWrites),
        "reliableWrite": false,
        "writableAuxiliaries": false,
      }
    };
  }
}
