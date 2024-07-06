import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:web_view_ble/src/models/ble_scan_filter.dart';
import 'package:web_view_ble/src/services/logger.dart';
import 'package:web_view_ble/src/models/web_ble_device.dart';

/// `getBleDeviceFromDialog` will return a BluetoothDevice and it will auto Show a Dialog to choose
Future<WebBleDevice?> getBleDeviceFromDialog({
  required BuildContext context,
  required BleScanFilter bleScanFilter,
}) async {
  if (!context.mounted) {
    logError("context is not mounted, failed to show dialog for scan results");
    return null;
  }
  Completer<WebBleDevice?> completer = Completer();
  await showAdaptiveDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog.adaptive(
        title: const Text("Choose Device"),
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.9,
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: _ChooseDevice((BleDevice device) {
            completer.complete(WebBleDevice.fromBleDevice(device));
            Navigator.of(context).pop();
          }, bleScanFilter),
        ),
        actions: [
          TextButton(
            onPressed: () {
              completer.complete(null);
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
  var result = await completer.future;
  return result;
}

class _ChooseDevice extends StatefulWidget {
  final Function(BleDevice) onSelect;
  final BleScanFilter bleScanFilter;
  const _ChooseDevice(this.onSelect, this.bleScanFilter);

  @override
  State<_ChooseDevice> createState() => __ChooseDeviceState();
}

class __ChooseDeviceState extends State<_ChooseDevice> {
  List<BleDevice> discoveredDevices = [];
  bool isScanning = false;
  String? error;
  bool? isBleOn;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  Future<void> initialize() async {
    try {
      var state = await UniversalBle.getBluetoothAvailabilityState();
      isBleOn = state == AvailabilityState.poweredOn;

      if (isBleOn == false) {
        setState(() {});
        return;
      }

      UniversalBle.onScanResult = (BleDevice device) {
        int? index =
            discoveredDevices.indexWhere((e) => e.deviceId == device.deviceId);
        if (index == -1) {
          setState(() {
            discoveredDevices.add(device);
          });
        } else {
          setState(() {
            discoveredDevices[index] = device;
          });
        }
      };

      await UniversalBle.startScan(scanFilter: scanFilter);

      setState(() {
        isScanning = true;
      });
    } catch (e) {
      error = e.toString();
      if (e is PlatformException) {
        error = e.message ?? e.toString();
      }
      setState(() {
        isScanning = false;
      });
      UniversalBle.startScan();
    }
  }

  @override
  void dispose() {
    UniversalBle.onScanResult = null;
    UniversalBle.stopScan();
    super.dispose();
  }

  ScanFilter? get scanFilter {
    logInfo("Scan Filter: ${widget.bleScanFilter}");
    ScanFilter? scanFilter;
    if (!widget.bleScanFilter.acceptAllDevices) {
      scanFilter = ScanFilter(
        withServices: List<String>.from(widget.bleScanFilter.services),
        withNamePrefix: List<String>.from(widget.bleScanFilter.namePrefix),
        withManufacturerData: widget.bleScanFilter.manufacturerData
            .map((e) => e.toMfdFilter())
            .toList(),
      );
    }
    return scanFilter;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    if (isBleOn == false) {
      return Center(
        child: Text(
          "Turn on Bluetooth",
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    if (isBleOn == null || isScanning && discoveredDevices.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Scrollbar(
      child: ListView.builder(
        itemCount: discoveredDevices.length,
        itemBuilder: (BuildContext context, int index) {
          BleDevice device = discoveredDevices[index];
          String name = device.name ?? "Unknown";
          if (name.isEmpty) name = "Unknown";
          return GestureDetector(
            onTap: () => widget.onSelect(device),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '$name (${device.rssi})',
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  device.deviceId,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
