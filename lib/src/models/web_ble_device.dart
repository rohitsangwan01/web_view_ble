import 'package:universal_ble/universal_ble.dart';

class WebBleDevice {
  String id;
  String name;

  WebBleDevice(this.id, this.name);

  factory WebBleDevice.fromBleDevice(BleDevice device) {
    return WebBleDevice(device.deviceId, device.name ?? "N/A");
  }

  Map<String, String> toJson() {
    return {"id": id, "name": name};
  }
}
