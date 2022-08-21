import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:web_view_ble/src/services/ble_service.dart';
import 'package:web_view_ble/web_view_ble.dart';

/// `getBleDeviceFromDialog` will return a BluetoothDevice and it will auto Show a Dialog to choose
Future<DiscoveredDevice?> getBleDeviceFromDialog(
  context, {
  bool? acceptAllDevice,
  List<Map<String, dynamic>>? filters,
}) async {
  BleService.to.bleDiscoveredDevicesList.clear();
  Completer<DiscoveredDevice?> completer = Completer();
  bool isCupertino = defaultTargetPlatform == TargetPlatform.iOS;
  _showDialog(
    context: context,
    completer: completer,
    isCupertino: isCupertino,
    acceptAllDevice: acceptAllDevice,
    filters: filters,
  );
  var result = await completer.future;
  return result;
}

/// Show Dialog
void _showDialog({
  required BuildContext context,
  required Completer completer,
  required bool isCupertino,
  required bool? acceptAllDevice,
  required List<Map<String, dynamic>>? filters,
}) {
  showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim1, anim2) => Theme(
      data: ThemeData.dark(),
      child: isCupertino
          ? _cupertinoAlertDialog(
              context,
              completer,
              acceptAllDevice: acceptAllDevice,
              filters: filters,
            )
          : _materialAlertDialog(
              context,
              completer,
              acceptAllDevice: acceptAllDevice,
              filters: filters,
            ),
    ),
    transitionBuilder: (ctx, anim1, anim2, child) => BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 4 * anim1.value,
        sigmaY: 4 * anim1.value,
      ),
      child: FadeTransition(
        opacity: anim1,
        child: child,
      ),
    ),
    context: context,
  );
}

// To Show Material Dialog For Android
AlertDialog _materialAlertDialog(
  context,
  completer, {
  bool? acceptAllDevice,
  List<Map<String, dynamic>>? filters,
}) {
  return AlertDialog(
    title: const Text("Choose Device"),
    content: ScanView(
      onSelect: (device) {
        completer.complete(device);
        Navigator.of(context).pop();
      },
      acceptAllDevice: acceptAllDevice,
      filters: filters,
    ),
    elevation: 2,
    actions: [
      ElevatedButton(
        child: const Text("Cancel"),
        onPressed: () {
          completer.complete(null);
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

// To Show Cupertino Dialog For iOS
CupertinoAlertDialog _cupertinoAlertDialog(
  context,
  completer, {
  bool? acceptAllDevice,
  List<Map<String, dynamic>>? filters,
}) {
  return CupertinoAlertDialog(
    title: const Text("Choose Device"),
    content: ScanView(
      onSelect: (device) {
        completer.complete(device);
        Navigator.of(context).pop();
      },
      acceptAllDevice: acceptAllDevice,
      filters: filters,
    ),
    actions: [
      CupertinoDialogAction(
        child: const Text("Cancel"),
        onPressed: () {
          completer.complete(null);
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

class ScanView extends StatelessWidget {
  final Function(DiscoveredDevice) onSelect;
  final bool? acceptAllDevice;
  final List<Map<String, dynamic>>? filters;
  const ScanView({
    Key? key,
    required this.onSelect,
    this.acceptAllDevice,
    this.filters,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.8,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: BleService.to.statusStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // Check for BleStatus Stream first
            BleStatus? status = snapshot.data;
            String message = status?.name ?? "None";
            if (status == null || status != BleStatus.ready) {
              return Center(
                child: Text("BLE ${message.toUpperCase()}"),
              );
            }

            List<Uuid> services = [];
            if (!(acceptAllDevice ?? true)) {
              services = BleService.to.getServicesFromFilter(filters);
            }
            return StreamBuilder(
              stream: BleService.to.flutterReactiveBle.scanForDevices(
                withServices: services,
              ),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error : ${snapshot.error}"),
                  );
                } else {
                  BleService.to.updateDiscoveredDevices(
                    snapshot.data,
                    acceptAllDevice: acceptAllDevice,
                    filters: filters,
                  );
                  if (BleService.to.bleDiscoveredDevicesList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DeviceListWidget(onSelect: onSelect);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class DeviceListWidget extends StatelessWidget {
  final Function(DiscoveredDevice) onSelect;
  const DeviceListWidget({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DiscoveredDevice> devices = BleService.to.bleDiscoveredDevicesList;
    return Scrollbar(
      child: ListView.builder(
        itemCount: BleService.to.bleDiscoveredDevicesList.length,
        itemBuilder: (BuildContext context, int index) {
          DiscoveredDevice device = devices[index];
          return Column(
            children: [
              ListTile(
                title:
                    device.name == "" ? const Text("N/A") : Text(device.name),
                subtitle: Text(device.id),
                onTap: () => onSelect(devices[index]),
              ),
              const Divider(height: 0, color: Colors.white, indent: 0),
            ],
          );
        },
      ),
    );
  }
}
