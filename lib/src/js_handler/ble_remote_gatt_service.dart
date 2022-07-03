// ignore_for_file: avoid_print

void registerRemoteGattService(controller) {
  // To Get charcteristic list
  controller.addJavaScriptHandler(
      handlerName: 'device:getCharacteristics',
      callback: (args) {
        print(args);
        return [""];
      });

  // To Get charcteristic
  controller.addJavaScriptHandler(
      handlerName: 'device:getCharacteristic',
      callback: (args) {
        print(args);
        return [""];
      });
}
