import 'package:web_view_ble/src/model/ble_service.dart';

import '../services/ble_service.dart';

void registerRemoteGattServer(controller) {
  // To connect
  controller.addJavaScriptHandler(
      handlerName: 'device:connectGATT',
      callback: (args) async {
        String deviceID = args[0]['data']['deviceId'];
        return await BleService.to.connect(deviceID);
      });

  // To disconnect
  controller.addJavaScriptHandler(
      handlerName: 'device:disconnectGATT',
      callback: (args) {
        String deviceID = args[0]['data']['deviceId'];
        BleService.to.disconnect(deviceID);
        return true;
      });

  // To Get Primary Services
  controller.addJavaScriptHandler(
      handlerName: 'device:getPrimaryServices',
      callback: (args) async {
        String deviceID = args[0]['data']['deviceId'];
        List<BleServiceModel> services =
            await BleService.to.discoverServices(deviceID);
        return services.map((e) => e.serviceId).toList();
      });
}
