(function () {
  "use strict";

  const wb = flowser.wb;
  const wbutils = flowser.wbutils;

  if (navigator.bluetooth) {
    // already exists, don't polyfill
    console.log("navigator.bluetooth already exists, skipping polyfill");
    return;
  }

  let native;

  function BluetoothGATTDescriptor(characteristic, uuid) {
    wbutils.defineROProperties(this, {
      characteristic: characteristic,
      uuid: uuid,
    });
  }

  BluetoothGATTDescriptor.prototype = {
    get writableAuxiliaries() {
      return this.value;
    },
    readValue: function () {
      throw new Error("Not implemented");
    },
    writeValue: function () {
      throw new Error("Not implemented");
    },
  };

  let bluetooth = {};

  //EventHandler onavailabilitychanged;

  bluetooth.getDevices = function () {
    console.log("Get Devices Called");
    return [];
  };

  bluetooth.getAvailability = function () {
    try {
      console.log("Get Availability Called");
      return window.flutter_inappwebview
        .callHandler("getAvailability")
        .then(function (result) {
          return result;
        });
    } catch (error) {
      console.error(error);
    }
  };

  // bluetooth.onavailabilitychanged = function () {
  //   console.log("onAvailability called");
  //   return window.flutter_inappwebview
  //     .callHandler("getAvailability")
  //     .then(function (result) {
  //       return result;
  //     });
  // };

  bluetooth.addEventListener = function () {
    console.log("addEventListener Called");
  };

  bluetooth.requestDevice = function (requestDeviceOptions) {
    if (!requestDeviceOptions) {
      return Promise.reject(new TypeError("requestDeviceOptions not provided"));
    }
    let acceptAllDevices = requestDeviceOptions.acceptAllDevices;
    let filters = requestDeviceOptions.filters;
    if (acceptAllDevices) {
      if (filters && filters.length > 0) {
        return Promise.reject(
          new TypeError("acceptAllDevices was true but filters was not empty")
        );
      }
      return native
        .sendMessage("requestDevice", { data: { acceptAllDevices: true } })
        .then(function (device) {
          return new wb.BluetoothDevice(device);
        });
    }

    if (!filters || filters.length === 0) {
      return Promise.reject(
        new TypeError("No filters provided and acceptAllDevices not set")
      );
    }
    try {
      filters = Array.prototype.map.call(filters, wbutils.canonicaliseFilter);
    } catch (e) {
      return Promise.reject(e);
    }
    let validatedDeviceOptions = {};
    validatedDeviceOptions.filters = filters;

    return native
      .sendMessage("requestDevice", { data: validatedDeviceOptions })
      .then(function (device) {
        return new wb.BluetoothDevice(device);
      });
  };

  function BluetoothEvent(type, target) {
    wbutils.defineROProperties(this, { type, target, srcElement: target });
  }

  BluetoothEvent.prototype = {
    prototype: Event.prototype,
    constructor: BluetoothEvent,
  };
  wb.BluetoothEvent = BluetoothEvent;

  //
  // ===== Communication with Native =====
  //
  native = {
    messageCount: 0,
    callbacks: {},
    characteristicsBeingNotified: {},
    devicesBeingNotified: {},
    cancelTransaction: function (tid) {
      let trans = this.callbacks[tid];
      if (!trans) {
        console.log(`No transaction ${tid} outstanding to fail.`);
        return;
      }
      delete this.callbacks[tid];
      trans(false, "Premature cancellation.");
    },
    getTransactionID: function () {
      let mc = this.messageCount;
      do {
        mc += 1;
      } while (native.callbacks[mc] !== undefined);
      this.messageCount = mc;
      return this.messageCount;
    },
    sendMessage: async function (type, sendMessageParms) {
      let message;
      if (type === undefined) {
        throw new Error("CallRemote should never be called without a type!");
      }

      sendMessageParms = sendMessageParms || {};
      let data = sendMessageParms.data || {};
      let callbackID = sendMessageParms.callbackID || this.getTransactionID();
      message = {
        type: type,
        data: data,
        callbackID: callbackID,
      };
      console.log(`Callback : ${type} | ID : ${callbackID}`);
      this.messageCount += 1;
      let result = await window.flutter_inappwebview.callHandler(type, {
        data: data,
        callbackID: callbackID,
      });
      if (result.error != undefined) {
        throw result.error;
      }
      return result;
    },
    receiveMessageResponse: function (success, resultString, callbackID) {
      if (callbackID !== undefined && native.callbacks[callbackID]) {
        native.callbacks[callbackID](success, resultString);
      } else {
        console.log(`Response for unknown callbackID ${callbackID}`);
      }
    },
    registerDeviceForNotifications: function (device) {
      let did = device.id;
      if (native.devicesBeingNotified[did] === undefined) {
        native.devicesBeingNotified[did] = [];
      }
      let devs = native.devicesBeingNotified[did];
      devs.forEach(function (dev) {
        if (dev === device) {
          throw new Error("Device already registered for notifications");
        }
      });
      console.log(`Register device ${did} for notifications`);
      devs.push(device);
    },
    unregisterDeviceForNotifications: function (device) {
      let did = device.id;
      if (native.devicesBeingNotified[did] === undefined) {
        return;
      }
      let devs = native.devicesBeingNotified[did];
      let ii;
      for (ii = 0; ii < devs.length; ii += 1) {
        if (devs[ii] === device) {
          devs.splice(ii, 1);
          return;
        }
      }
    },
    receiveDeviceDisconnectEvent: function (deviceId) {
      console.log(`${deviceId} disconnected`);
      let devices = native.devicesBeingNotified[deviceId];
      if (devices !== undefined) {
        devices.forEach(function (device) {
          device.handleSpontaneousDisconnectEvent();
          native.unregisterDeviceForNotifications(device);
        });
      }
      native.characteristicsBeingNotified[deviceId] = undefined;
    },
    registerCharacteristicForNotifications: function (characteristic) {
      let did = characteristic.service.device.id;
      let cid = characteristic.uuid;
      console.log(`Registering char UUID ${cid} on device ${did}`);

      if (native.characteristicsBeingNotified[did] === undefined) {
        native.characteristicsBeingNotified[did] = {};
      }
      let chars = native.characteristicsBeingNotified[did];
      if (chars[cid] === undefined) {
        chars[cid] = [];
      }
      chars[cid].push(characteristic);
    },
    receiveCharacteristicValueNotification: function (deviceId, cname, d64) {
      console.log("receiveCharacteristicValueNotification");
      const cid = window.BluetoothUUID.getCharacteristic(cname);
      let devChars = native.characteristicsBeingNotified[deviceId];
      let chars = devChars && devChars[cid];
      if (chars === undefined) {
        console.log(
          "Unexpected characteristic value notification for device " +
            `${deviceId} and characteristic ${cid}`
        );
        return;
      }
      console.log("<-- char val notification", cid, d64);
      chars.forEach(function (char) {
        let dataView = wbutils.str64todv(d64);
        char.value = dataView;
        char.dispatchEvent(
          new BluetoothEvent("characteristicvaluechanged", char)
        );
      });
    },
    enableBluetooth: function () {
      // weirdly this can get overwritten, so add a way to enable it.
      navigator.bluetooth = bluetooth;
    },
    BluetoothRemoteGATTCharacteristic: wb.BluetoothRemoteGATTCharacteristic,
    BluetoothRemoteGATTServer: wb.BluetoothRemoteGATTServer,
    BluetoothRemoteGATTService: wb.BluetoothRemoteGATTService,
    BluetoothEvent: BluetoothEvent,
  };
  // Exposed interfaces
  wb.native = native;
  window.iOSNativeAPI = native;
  window.BluetoothDevice = wb.BluetoothDevice;
  window.BluetoothRemoteGATTCharacteristic =
    wb.BluetoothRemoteGATTCharacteristic;
  window.BluetoothRemoteGATTServer = wb.BluetoothRemoteGATTServer;
  window.BluetoothRemoteGATTService = wb.BluetoothRemoteGATTService;
  window.receiveMessageResponse = native.receiveMessageResponse;
  window.receiveCharacteristicValueNotification =
    native.receiveCharacteristicValueNotification;
  window.receiveDeviceDisconnectEvent = native.receiveDeviceDisconnectEvent;

  native.enableBluetooth();
  function open(location) {
    window.location = location;
  }
  window.open = open;

  // Event Handlers from Dart
  window.addEventListener(
    "flutterEventListener",
    (event) => {
      console.log(JSON.stringify(event.detail));
    },
    false
  );

  // Connection Event Listener
  window.addEventListener(
    "flutterConnectionEventListener",
    (event) => {
      let data = JSON.stringify(event.detail);
      const myObj = JSON.parse(data);
      let isConnected = myObj.state;
      let deviceId = myObj.deviceId;
      if (!isConnected) {
        native.receiveDeviceDisconnectEvent(deviceId);
      }
    },
    false
  );

  // Chacteristics Events Listener
  window.addEventListener(
    "flutterCharacteristicsEventListener",
    (event) => {
      let data = JSON.stringify(event.detail);
      const myObj = JSON.parse(data);
      native.receiveCharacteristicValueNotification(
        myObj.deviceId,
        myObj.cname,
        myObj.d64
      );
    },
    false
  );

  // Availability Change Listener
  window.addEventListener(
    "flutterAvailabilityChangeEventListener",
    (event) => {
      let data = JSON.stringify(event.detail);
      const myObj = JSON.parse(data);
      const isAvailable = myObj.isAvailable;
      console.log(`BleStatus : ${isAvailable}`);
      const availabilitychangedEvent = new CustomEvent("availabilitychanged", {
        status: isAvailable,
      });
      window.dispatchEvent(availabilitychangedEvent);
    },
    false
  );
})();
