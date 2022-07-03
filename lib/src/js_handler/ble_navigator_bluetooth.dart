import 'package:web_view_ble/src/model/ble_device.dart';
import '../services/ble_service.dart';

///`navigator.bluetooth`
void registerNavigatorBluetooth(controller) {
  ///[Request Device]
  controller.addJavaScriptHandler(
      handlerName: 'requestDevice',
      callback: (args) async {
        BleDevice? device = await BleService.to.getBleDevice();
        if (device == null) {
          throw "Device not selected";
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
