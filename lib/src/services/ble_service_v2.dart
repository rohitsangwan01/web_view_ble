// // ignore_for_file: avoid_print

// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:quick_blue/quick_blue.dart';
// import 'package:web_view_ble/src/model/ble_device.dart';
// import 'package:web_view_ble/src/model/ble_service.dart';

// import '../helper/resolve_char.dart';
// import '../widgets/scan_dialog.dart';

// class BleService {
//   static BleService? _instance;
//   BleService._();
//   static BleService get to => _instance ??= BleService._();

//   late BuildContext _context;

//   List<BleDevice> discoveredDevicesList = <BleDevice>[];

//   StreamSubscription? _scanSubscription;

//   late StreamController _servicesStreamController;
//   late StreamController _valueStreamController;
//   late StreamController _connectionStreamController;

//   Stream<BlueScanResult> scnaStream = QuickBlue.scanResultStream;

//   Map<String, List<BleServiceModel>> servicesMap = {};

//   Future<bool> getAvailability() async {
//     return await QuickBlue.isBluetoothAvailable();
//   }

//   void init(BuildContext context) {
//     _context = context;

//     // initialize Streams
//     _servicesStreamController = StreamController.broadcast();
//     _connectionStreamController = StreamController.broadcast();
//     _valueStreamController = StreamController.broadcast();

//     // initialize QuickBlue Handlers
//     QuickBlue.setServiceHandler((deviceID, serviceId, characteristicIds) {
//       _servicesStreamController.add({
//         'deviceID': deviceID,
//         'serviceId': serviceId,
//         'characteristicIds': characteristicIds,
//       });
//     });

//     QuickBlue.setConnectionHandler((deviceId, state) {
//       _connectionStreamController.add({
//         'deviceID': deviceId,
//         'connected': state == BlueConnectionState.connected,
//       });
//     });

//     QuickBlue.setValueHandler(
//         (String deviceId, String characteristicId, Uint8List value) {
//       _valueStreamController.add({
//         'deviceID': deviceId,
//         'characteristicId': characteristicId,
//         'value': value,
//       });
//     });
//   }

//   startScan() {
//     discoveredDevicesList.clear();
//     _scanSubscription = scnaStream.listen((event) {
//       if (!discoveredDevicesList
//           .any((element) => element.id == event.deviceId)) {
//         discoveredDevicesList
//             .add(BleDevice(name: event.name, id: event.deviceId));
//       }
//     });
//     QuickBlue.startScan();
//   }

//   stopScan() {
//     QuickBlue.stopScan();
//     _scanSubscription?.cancel();
//   }

//   Future<BleDevice?> getBleDevice() async => getBleDeviceFromDialog(_context);

//   Future<bool> connect(deviceId,
//       {Duration timeout = const Duration(seconds: 5)}) async {
//     QuickBlue.connect(deviceId);
//     var result = await _connectionStreamController.stream.timeout(timeout,
//         onTimeout: (sink) {
//       QuickBlue.disconnect(deviceId);
//       return sink.add(null);
//     }).firstWhere((element) => element['deviceID'] == deviceId);
//     if (result == null) {
//       return false;
//     } else {
//       return result['connected'];
//     }
//   }

//   disconnect(deviceId) async {
//     QuickBlue.disconnect(deviceId);
//   }

//   Future<List<BleServiceModel>> discoverServices(deviceId) async {
//     List<BleServiceModel>? servicesListMap = servicesMap[deviceId];
//     if (servicesListMap != null) {
//       return servicesListMap;
//     }
//     List<BleServiceModel> servicesList = [];
//     late StreamSubscription servicesStreamSubscription;
//     servicesStreamSubscription = _servicesStreamController.stream
//         .where((event) => event['deviceID'] == deviceId)
//         .listen((event) {
//       servicesList.add(BleServiceModel(
//           serviceId: event['serviceId'],
//           characteristics: event['characteristicIds']));
//     });
//     QuickBlue.discoverServices(deviceId);
//     //just a workaround for now to discover services
//     await Future.delayed(const Duration(seconds: 1));
//     servicesStreamSubscription.cancel();
//     servicesMap[deviceId] = servicesList;
//     return servicesList;
//   }

//   Future readCharacteristics(
//     String characteristicsId,
//     String servicesId,
//     String deviceId,
//   ) async {
//     characteristicsId = convertToiOSUid(characteristicsId);
//     servicesId = convertToiOSUid(servicesId);
//     print("$servicesId  $characteristicsId");
//     await QuickBlue.readValue(deviceId, servicesId, characteristicsId);
//     var result = await _valueStreamController.stream
//         .timeout(const Duration(seconds: 4), onTimeout: (sink) {
//       return sink.add(null);
//     }).firstWhere((event) {
//       return event == null ||
//           event['deviceID'] == deviceId &&
//               event['characteristicId'] == characteristicsId;
//     });

//     return result?['value'];
//   }

//   Future writeCharacteristics(String characteristicsId, String servicesId,
//       String deviceId, Uint8List value, bool writeWithResponse) async {
//     characteristicsId = convertToiOSUid(characteristicsId);
//     servicesId = convertToiOSUid(servicesId);
//     await QuickBlue.writeValue(
//         deviceId,
//         servicesId,
//         characteristicsId,
//         value,
//         writeWithResponse
//             ? BleOutputProperty.withResponse
//             : BleOutputProperty.withoutResponse);
//   }
// }
