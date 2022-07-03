// import 'dart:async';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:web_view_ble/src/model/ble_device.dart';
// import 'package:web_view_ble/src/model/ble_service.dart';

// import '../widgets/scan_dialog.dart';

// class BleService {
//   static BleService? _instance;
//   BleService._();
//   static BleService get to => _instance ??= BleService._();

//   late BuildContext _context;

//   final flutterReactiveBle = FlutterReactiveBle();
//   List<BleDevice> discoveredDevicesList = <BleDevice>[];

//   StreamSubscription? _scanSubscription;

//   late StreamController<BleDevice> _scanStreamController;

//   Stream<BleDevice> get scnaStream => _scanStreamController.stream;

//   Map<String, List<BleServiceModel>> servicesMap = {};
//   Map<String, StreamSubscription> connectionMap = {};

//   void init(BuildContext context) {
//     _context = context;
//     // initialize Streams
//     _scanStreamController = StreamController.broadcast();
//   }

//   startScan() {
//     discoveredDevicesList.clear();
//     _scanSubscription =
//         flutterReactiveBle.scanForDevices(withServices: []).listen((event) {
//       if (!discoveredDevicesList.any((element) => element.id == event.id)) {
//         BleDevice device = BleDevice(name: event.name, id: event.id);
//         discoveredDevicesList.add(device);
//         _scanStreamController.add(device);
//       }
//     });
//   }

//   stopScan() {
//     _scanSubscription?.cancel();
//   }

//   Future<BleDevice?> getBleDevice() async => getBleDeviceFromDialog(_context);

//   Future<bool> connect(deviceId,
//       {Duration timeout = const Duration(seconds: 5)}) async {
//     Completer<bool> completer = Completer();
//     late Timer timer;
//     late StreamSubscription connectionStreamSubscription;
//     timer = Timer(timeout, () {
//       connectionStreamSubscription.cancel();
//       completer.complete(false);
//     });
//     connectionStreamSubscription = flutterReactiveBle
//         .connectToDevice(id: deviceId, connectionTimeout: timeout)
//         .listen((event) {
//       if (event.connectionState == DeviceConnectionState.connected ||
//           event.connectionState == DeviceConnectionState.disconnected) {
//         timer.cancel();
//         completer
//             .complete(event.connectionState == DeviceConnectionState.connected);
//       }
//     });

//     bool isConnected = await completer.future;
//     if (isConnected) {
//       connectionMap[deviceId] = connectionStreamSubscription;
//     }
//     return isConnected;
//   }

//   disconnect(deviceId) async {
//     StreamSubscription? connectionStream = connectionMap[deviceId];
//     if (connectionStream != null) {
//       connectionStream.cancel();
//       connectionMap.remove(deviceId);
//     }
//   }

//   Future<List<BleServiceModel>> discoverServices(deviceId) async {
//     List<BleServiceModel>? servicesListMap = servicesMap[deviceId];
//     if (servicesListMap != null) {
//       return servicesListMap;
//     }

//     List<DiscoveredService> services =
//         await flutterReactiveBle.discoverServices(deviceId);

//     List<BleServiceModel> servicesList = services
//         .map((e) => BleServiceModel(
//             serviceId: e.serviceId.toString(),
//             characteristics:
//                 e.characteristicIds.map((e) => e.toString()).toList()))
//         .toList();

//     servicesMap[deviceId] = servicesList;
//     return servicesList;
//   }
// }
