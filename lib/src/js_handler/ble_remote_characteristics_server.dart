// ignore_for_file: avoid_print

import 'package:web_view_ble/src/services/ble_service.dart';

void registerRemoteCharacteristicsGattServer(controller) {
  //To read charcteristic
  controller.addJavaScriptHandler(
      handlerName: 'device:readCharacteristicValue',
      callback: (args) async {
        String deviceID = args[0]['data']['deviceId'];
        String characteristicUUID = args[0]['data']['characteristicUUID'];
        String serviceUUID = args[0]['data']['serviceUUID'];
        var data = await BleService.to
            .readCharacteristics(characteristicUUID, serviceUUID, deviceID);
        print(data);
        if (data == null) {
          throw Exception('Error reading characteristic');
        }
        return data;
      });

  //To write charcteristic
  controller.addJavaScriptHandler(
      handlerName: 'device:writeCharacteristicValue',
      callback: (args) async {
        String deviceID = args[0]['data']['deviceId'];
        String characteristicUUID = args[0]['data']['characteristicUUID'];
        String serviceUUID = args[0]['data']['serviceUUID'];
        var value = args[0]['data']['value'];
        bool writeWithResponse = true;
        await BleService.to.writeCharacteristics(characteristicUUID,
            serviceUUID, deviceID, value, writeWithResponse);
      });

  //To Start Notification
  controller.addJavaScriptHandler(
      handlerName: 'device:startNotifications',
      callback: (args) {
        print(args);
      });

  //To Stop Notification
  controller.addJavaScriptHandler(
      handlerName: 'device:stopNotifications',
      callback: (args) {
        print(args);
      });
}
