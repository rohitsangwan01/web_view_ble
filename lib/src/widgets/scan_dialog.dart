import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_view_ble/src/services/ble_service.dart';

import '../model/ble_device.dart';

Future<BleDevice?> getBleDeviceFromDialog(context) async {
  BleService.to.startScan();
  Completer<BleDevice?> completer = Completer();
  showCupertinoDialog(
    context: context,
    builder: (context) {
      return Theme(
        data: ThemeData.dark(),
        child: CupertinoAlertDialog(
          title: const Text("Choose Device"),
          content: ScanView(onSelect: (device) {
            completer.complete(device);
            Navigator.of(context).pop();
          }),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                completer.complete(null);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
  var result = await completer.future;
  BleService.to.stopScan();
  return result;
}

// ignore: must_be_immutable
class ScanView extends StatelessWidget {
  Function onSelect;
  ScanView({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 1.8,
        child: StreamBuilder(
          stream: BleService.to.scnaStream,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return ListView.builder(
              itemCount: BleService.to.discoveredDevicesList.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    ListTile(
                      title: BleService.to.discoveredDevicesList[index].name ==
                              ""
                          ? const Text("N/A")
                          : Text(
                              BleService.to.discoveredDevicesList[index].name),
                      subtitle:
                          Text(BleService.to.discoveredDevicesList[index].id),
                      onTap: () {
                        onSelect(BleService.to.discoveredDevicesList[index]);
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
