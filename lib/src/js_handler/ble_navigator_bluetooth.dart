import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../services/ble_service.dart';

///`navigator.bluetooth`
void registerNavigatorBluetooth(InAppWebViewController controller) {
  ///[Request Device]
  controller.addJavaScriptHandler(
      handlerName: 'requestDevice',
      callback: (args) async {
        DiscoveredDevice? device = await BleService.to.getBleDevice(args);
        if (device == null) {
          return {"error": "No Device Selected "};
        }
        return {
          "name": device.name,
          "id": device.id,
        };
      });

  /// To [GetAvailability]
  controller.addJavaScriptHandler(
      handlerName: 'getAvailability',
      callback: (args) async {
        return await BleService.to.getAvailability();
      });
}
