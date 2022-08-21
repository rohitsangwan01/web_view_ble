import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'ble_remote_characteristics_server.dart';
import 'ble_remote_gatt_server.dart';
import 'ble_remote_gatt_service.dart';
import 'ble_navigator_bluetooth.dart';

class JsHandler {
  InAppWebViewController webViewController;
  JsHandler({required this.webViewController});

// register a JavaScript handler with name "myHandlerName"
  Future<void> addHandlers() async {
    ///`RequestDevice` , `GetAvailability`
    registerNavigatorBluetooth(webViewController);

    ///`connect` `disconnect` `getPrimaryService` `getPrimaryServices`
    registerRemoteGattServer(webViewController);

    ///`getCharacteristic` `getCharacteristics`
    registerRemoteGattService(webViewController);

    ///Characteristics : `read` `write` `notify` `disable`
    registerRemoteCharacteristicsGattServer(webViewController);
  }
}
