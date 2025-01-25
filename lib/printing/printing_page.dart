import 'dart:async';
import 'dart:developer';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:bluetooth_printing/printing/printer_controller.dart';
import 'package:flutter/material.dart';

class PrintingPage extends StatefulWidget {
  const PrintingPage({
    super.key,
  });

  @override
  State<PrintingPage> createState() => _PrintingPageState();
}

class _PrintingPageState extends State<PrintingPage> {
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    initConnection();
    super.initState();
  }

  initConnection() async {
    await PrintController.instance.checkBluetoothAndScanDevices();
    final _devices = await PrintController.instance.scanDevices();
    setState(() {
      devices = _devices;
      log('devices: Home $devices');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrintPlus'),
        ),
        body: SafeArea(
            child: ListView(
          children: devices
              .map((device) => Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(device.name ?? ''),
                            Text(
                              device.address ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const Divider(),
                          ],
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        // OutlinedButton(
                        //   onPressed: () async {
                        //     bool isConnected = await PrintController
                        //             .instance.bluetoothPrint
                        //             .isDeviceConnected(device) ??
                        //         false;
                        //     print("isConnected: $isConnected");
                        //     if (!isConnected) {
                        //       PrintController.instance.bluetoothPrint
                        //           .connect(device);
                        //       initConnection();
                        //     } else {
                        //       PrintController.instance.bluetoothPrint
                        //           .disconnect();
                        //       initConnection();
                        //     }
                        //   },
                        //   child: FutureBuilder<bool?>(
                        //       future: PrintController.instance.bluetoothPrint
                        //           .isDeviceConnected(device),
                        //       builder: (context, snapshot) {
                        //         if (snapshot.hasData) {
                        //           return Text(snapshot.data!
                        //               ? "disconnect"
                        //               : "connect");
                        //         }
                        //         return SizedBox();
                        //       }),
                        // ),

                        OutlinedButton(
                          onPressed: () async {
                            PrintController.instance.printInvoice(device);
                          },
                          child: FutureBuilder<bool?>(
                              future: PrintController.instance.bluetoothPrint
                                  .isDeviceConnected(device),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text("print");
                                }
                                return SizedBox();
                              }),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        )),
        // );
        floatingActionButton: !PrintController.instance.isScanning
            ? buildScanButton(context)
            : null);
  }

  Widget buildBlueOffWidget() {
    return const Center(
        child: Text(
      "Bluetooth is turned off\nPlease turn on Bluetooth...",
      style: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 16, color: Colors.red),
      textAlign: TextAlign.center,
    ));
  }

  Widget buildScanButton(BuildContext context) {
    if (PrintController.instance.isScanning) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
          onPressed: onScanPressed,
          backgroundColor: Colors.green,
          child: const Text("SCAN"));
    }
  }

  Future onScanPressed() async {
    try {
      await initConnection();
    } catch (e) {
      debugPrint("onScanPressed error: $e");
    }
  }

  Future onStopPressed() async {
    try {
      // BluetoothPrintPlus.stopScan();
    } catch (e) {
      debugPrint("onStopPressed error: $e");
    }
  }
}
