// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:web_view_ble/src/helper/resolve_char.dart';
import 'package:web_view_ble/src/model/ble_device.dart';
import 'package:web_view_ble/src/services/dart_to_js.dart';
import 'package:web_view_ble/web_view_ble.dart';
import '../widgets/scan_dialog.dart';

class BleService {
  static BleService? _instance;
  BleService._();
  static BleService get to => _instance ??= BleService._();

  late BuildContext _context;

  final flutterReactiveBle = FlutterReactiveBle();

  List<BleDevice> discoveredDevicesList = <BleDevice>[];

  StreamSubscription? _scanSubscription;

  late StreamController<BleDevice> _scanStreamController;

  Stream<BleDevice> get scanStream => _scanStreamController.stream;

  Map<String, StreamSubscription> connectionMap = {};
  Map<QualifiedCharacteristic, StreamSubscription>
      characteristicSubscriptionMap = {};

  void init(BuildContext context) {
    _context = context;
    // initialize Streams
    _scanStreamController = StreamController.broadcast();
  }

  startScan() {
    discoveredDevicesList.clear();
    _scanSubscription =
        flutterReactiveBle.scanForDevices(withServices: []).listen((event) {
      if (!discoveredDevicesList.any((element) => element.id == event.id)) {
        BleDevice device = BleDevice(name: event.name, id: event.id);
        discoveredDevicesList.add(device);
        _scanStreamController.add(device);
      }
    });
  }

  stopScan() {
    _scanSubscription?.cancel();
  }

  Future<bool> getAvailability() async {
    BleStatus status = flutterReactiveBle.status;
    logSuccess("Ble Availability: ${status.toString()}");
    return status == BleStatus.ready;
  }

  Future<BleDevice?> getBleDevice() async => getBleDeviceFromDialog(_context);

  Future getCharacteristics(serviceUUID, deviceID) async {
    DiscoveredService? service =
        await _getService(deviceId: deviceID, serviceId: serviceUUID);
    if (service == null) return null;
    var characteristics =
        service.characteristics.map((e) => _characteristicsToJson(e)).toList();
    return characteristics;
  }

  Future getCharacteristic(characteristicUUID, serviceUUID, deviceID) async {
    DiscoveredService? service =
        await _getService(deviceId: deviceID, serviceId: serviceUUID);
    if (service == null) return null;
    DiscoveredCharacteristic? characteristic =
        service.characteristics.firstWhereOrNull(
      (element) => element.characteristicId.toString() == characteristicUUID,
    );
    if (characteristic == null) return null;
    return _characteristicsToJson(characteristic);
  }

  Future<bool> connect(deviceId,
      {Duration timeout = const Duration(seconds: 5)}) async {
    Completer<bool> completer = Completer();
    late Timer timer;
    StreamSubscription? connectionStreamSubscription;
    timer = Timer(timeout, () {
      connectionStreamSubscription?.cancel();
      completer.complete(false);
    });
    connectionStreamSubscription = flutterReactiveBle
        .connectToDevice(id: deviceId, connectionTimeout: timeout)
        .listen((event) {
      if (event.connectionState == DeviceConnectionState.connected ||
          event.connectionState == DeviceConnectionState.disconnected) {
        timer.cancel();
        bool isConnected =
            event.connectionState == DeviceConnectionState.connected;
        // Also send to Javascript
        DartToJs.to.dispatchJsEvent(event: JsEvents.connectionEvent, data: {
          "deviceId": deviceId,
          "state": isConnected,
        });
        completer.complete(isConnected);
      }
    });
    bool isConnected = await completer.future;
    if (isConnected) {
      connectionMap[deviceId] = connectionStreamSubscription;
    }
    return isConnected;
  }

  disconnect(deviceId) async {
    StreamSubscription? connectionStream = connectionMap[deviceId];
    if (connectionStream != null) {
      connectionStream.cancel();
      connectionMap.remove(deviceId);
    }
  }

  Future<List<String>> discoverServices(deviceId) async {
    List<DiscoveredService> services =
        await flutterReactiveBle.discoverServices(deviceId);
    return services.map((e) => validateUUid(e.serviceId.toString())).toList();
  }

  Future<void> writeCharacteristics(characteristicUUID, serviceUUID, deviceID,
      value, bool writeWithResponse) async {
        var code = base64.decode(value);
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(characteristicUUID),
        serviceId: Uuid.parse(serviceUUID),
        deviceId: deviceID);
    if (writeWithResponse) {
      await flutterReactiveBle.writeCharacteristicWithResponse(
        characteristic,
        value: code,
      );
    } else {
      await flutterReactiveBle.writeCharacteristicWithoutResponse(
        characteristic,
        value: code,
      );
    }
  }

  // Convert bytes to base64 String
  Future<String> readCharacteristics(
      characteristicUUID, serviceUUID, deviceID) async {
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(characteristicUUID),
        serviceId: Uuid.parse(serviceUUID),
        deviceId: deviceID);
    List<int> data =
        await flutterReactiveBle.readCharacteristic(characteristic);
    return base64.encode(data);
  }

  subscribeCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) {
    QualifiedCharacteristic characteristic = QualifiedCharacteristic(
        characteristicId: Uuid.parse(characteristicUUID),
        serviceId: Uuid.parse(serviceUUID),
        deviceId: deviceID);
    late StreamSubscription characteristicSubscription;
    characteristicSubscription = flutterReactiveBle
        .subscribeToCharacteristic(characteristic)
        .listen((List<int> event) {
      String base64Event = base64.encode(event);
      DartToJs.to
          .updateCharacteristicsData(deviceID, characteristicUUID, base64Event);
    });
    characteristicSubscriptionMap[characteristic] = characteristicSubscription;
  }

  unSubscribeCharacteristics({
    required String characteristicUUID,
    required String serviceUUID,
    required String deviceID,
  }) {
    characteristicSubscriptionMap.forEach((characteristic, subscription) {
      if (characteristic.characteristicId.toString() == characteristicUUID &&
          characteristic.serviceId.toString() == serviceUUID &&
          characteristic.deviceId.toString() == deviceID) {
        subscription.cancel();
        characteristicSubscriptionMap.remove(characteristic);
      }
    });
  }

  // helper Methods

  Future<DiscoveredService?> _getService({
    required String deviceId,
    required String serviceId,
  }) async {
    List<DiscoveredService> services =
        await flutterReactiveBle.discoverServices(deviceId);
    DiscoveredService? service = services.firstWhereOrNull(
      (DiscoveredService service) => service.serviceId.toString() == serviceId,
    );
    if (service == null) return null;
    return _validateService(service);
  }

  DiscoveredService _validateService(DiscoveredService service) {
    Uuid validService = Uuid.parse(validateUUid(service.serviceId.toString()));
    List<Uuid> validCharacteristics = service.characteristicIds
        .map((e) => Uuid.parse(validateUUid(e.toString())))
        .toList();
    List<DiscoveredCharacteristic> characersitics = service.characteristics
        .map((e) => DiscoveredCharacteristic(
              characteristicId:
                  Uuid.parse(validateUUid(e.characteristicId.toString())),
              serviceId: validService,
              isReadable: e.isReadable,
              isWritableWithResponse: e.isWritableWithResponse,
              isWritableWithoutResponse: e.isWritableWithoutResponse,
              isNotifiable: e.isNotifiable,
              isIndicatable: e.isIndicatable,
            ))
        .toList();
    return DiscoveredService(
        serviceId: validService,
        characteristicIds: validCharacteristics,
        characteristics: characersitics);
  }

  Map<String, dynamic> _characteristicsToJson(
      DiscoveredCharacteristic characteristic) {
    var data = {
      "uuid": characteristic.characteristicId.toString(),
      "properties": {
        "read": characteristic.isReadable,
        "write": characteristic.isWritableWithResponse,
        "writeWithoutResponse": characteristic.isWritableWithoutResponse,
        "notify": characteristic.isNotifiable,
        "broadcast": characteristic.isNotifiable,
        "indicate": characteristic.isIndicatable,
        "authenticatedSignedWrites": false,
        "reliableWrite": false,
        "writableAuxiliaries": false,
      }
    };
    return data;
  }
}
