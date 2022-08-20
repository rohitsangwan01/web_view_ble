import 'package:web_view_ble/web_view_ble.dart';
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
        logInfo(args.toString());
        String deviceID = args[0]['data']['deviceId'];
        String? serviceUUID;
        if (args.toString().contains('serviceUUID')) {
          serviceUUID = args[0]['data']['serviceUUID'];
        }
        List<String> servicesList =
            await BleService.to.discoverServices(deviceID);
        if (serviceUUID != null) {
          if (servicesList.contains(serviceUUID)) {
            return [serviceUUID];
          } else {
            return [];
          }
        } else {
          return servicesList;
        }
      });
}
