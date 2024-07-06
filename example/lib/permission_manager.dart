// ignore_for_file: avoid_print

import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> validatePermissions() async {
  var status = await _getPermissionStatus();
  bool blePermissionGranted = status.bleStatus;
  bool locationPermissionGranted = status.locationStatus;
  bool hasPermission = blePermissionGranted && locationPermissionGranted;
  print(status.toString());
  if (hasPermission) return true;

  if (!blePermissionGranted) {
    var blePermissionCheck = await Permission.bluetooth.request();

    if (blePermissionCheck.isPermanentlyDenied) {
      print("Permanently denied, opening settings");
      // openAppSettings();
    }
    return false;
  }

  if (!locationPermissionGranted) {
    var locationPermissionCheck = await Permission.location.request();

    if (locationPermissionCheck.isPermanentlyDenied) {
      print("Permanently denied, opening settings");
      // openAppSettings();
    }
    return false;
  }

  return false;
}

Future<({bool locationStatus, bool bleStatus})> _getPermissionStatus() async {
  bool blePermissionGranted = false;
  bool locationPermissionGranted = false;

  if (await _requiresExplicitAndroidBluetoothPermissions) {
    bool bleConnectPermission =
        await Permission.bluetoothConnect.request().isGranted;
    bool bleScanPermission = await Permission.bluetoothScan.request().isGranted;
    bool bleAdvertisePermission =
        await Permission.bluetoothAdvertise.request().isGranted;
    blePermissionGranted =
        bleConnectPermission && bleScanPermission && bleAdvertisePermission;
    locationPermissionGranted = true;
  } else {
    blePermissionGranted = await Permission.bluetooth.request().isGranted;
    locationPermissionGranted = await _requiresLocationPermission
        ? await Permission.locationWhenInUse.request().isGranted
        : true;
  }
  return (
    locationStatus: locationPermissionGranted,
    bleStatus: blePermissionGranted,
  );
}

Future<bool> get _requiresExplicitAndroidBluetoothPermissions async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  return androidInfo.version.sdkInt >= 31;
}

Future<bool> get _requiresLocationPermission async {
  return !kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android &&
          (!await _requiresExplicitAndroidBluetoothPermissions);
}
