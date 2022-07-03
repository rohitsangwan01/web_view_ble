(function () {
  "use strict";

  const wb = flowser.wb;
  const wbutils = flowser.wbutils;

  function BluetoothRemoteGATTCharacteristic(service, uuid, properties) {
    let roProps = {
      service: service,
      properties: properties,
      uuid: uuid,
    };
    wbutils.defineROProperties(this, roProps);
    this.value = null;
    wbutils.EventTarget.call(this);
    wb.native.registerCharacteristicForNotifications(this);
  }

  BluetoothRemoteGATTCharacteristic.prototype = {
    getDescriptor: function () {
      throw new Error("Not implemented");
    },
    getDescriptors: function () {
      throw new Error("Not implemented");
    },
    readValue: function () {
      let char = this;
      return this.sendMessage("readCharacteristicValue").then(function (
        valueEncoded
      ) {
        char.value = wbutils.str64todv(valueEncoded);
        return char.value;
      });
    },
    writeValue: function (value) {
      // value may be an ArrayBuffer or a TypedArray (view onto an ArrayBuffer). Either way, we
      // create a new Uint8Array to hold it and defer to the built-in methods for translating
      // between views.
      const buffer = new Uint8Array(value);

      // Can't send raw array bytes since we use JSON, so base64 encode.
      let v64 = wbutils.uint8ArrayToBase64(buffer);
      return this.sendMessage("writeCharacteristicValue", {
        data: { value: v64 },
      });
    },
    startNotifications: function () {
      return this.sendMessage("startNotifications").then(() => this);
    },
    stopNotifications: function () {
      return this.sendMessage("stopNotifications").then(() => this);
    },
    sendMessage: function (type, messageParms) {
      messageParms = messageParms || {};
      messageParms.data = messageParms.data || {};
      messageParms.data.characteristicUUID = this.uuid;
      return this.service.sendMessage(type, messageParms);
    },
    toString: function () {
      return `BluetoothRemoteGATTCharacteristic(${this.service.toString()}, ${
        this.uuid
      })`;
    },
  };
  wbutils.mixin(BluetoothRemoteGATTCharacteristic, wbutils.EventTarget);
  wb.BluetoothRemoteGATTCharacteristic = BluetoothRemoteGATTCharacteristic;
})();
