import 'package:web_view_ble/src/services/ble_service.dart';
import 'package:web_view_ble/web_view_ble.dart';

void registerRemoteGattService(controller) {
  // To Get charcteristic list
  controller.addJavaScriptHandler(
      handlerName: 'device:getCharacteristics',
      callback: (args) async {
        logInfo('get Characteritics Called');
        logInfo(args.toString());
        String deviceID = args[0]['data']['deviceId'];
        String serviceUUID = args[0]['data']['serviceUUID'];
        var data =
            await BleService.to.getCharacteristics(serviceUUID, deviceID);
        return data;
      });

  // To Get charcteristic
  controller.addJavaScriptHandler(
      handlerName: 'device:getCharacteristic',
      callback: (args) async {
        logInfo('get Characteritic Called');
        logInfo(args.toString());
        String deviceID = args[0]['data']['deviceId'];
        String characteristicUUID = args[0]['data']['characteristicUUID'];
        String serviceUUID = args[0]['data']['serviceUUID'];
        var data = await BleService.to
            .getCharacteristic(characteristicUUID, serviceUUID, deviceID);
        return data;
      });
}
