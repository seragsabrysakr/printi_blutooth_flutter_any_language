import 'dart:developer';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:bluetooth_printing/core/toast_helper.dart';
import 'package:bluetooth_printing/printing/printing_data.dart';
import 'package:bluetooth_printing/printing/printing_helper.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;

class PrintController {
  PrintController._();

  static final PrintController _instance = PrintController._();

  static PrintController get instance => _instance;
  List<BluetoothDevice> devices = [];
  BlueThermalPrinter bluetoothPrint = BlueThermalPrinter.instance;
  bool isScanning = false;

  Future<void> printInvoice(BluetoothDevice selectedDevice) async {
    try {
      if (!selectedDevice.connected) {
        try {
          await bluetoothPrint.connect(selectedDevice);
        } catch (e) {
          showToastError(e.toString());
        }
      }

      Uint8List? logo = await generateImage(PrintingData().logo());
      Uint8List? companyImg = await generateImage(PrintingData().compnayName());
      Uint8List? branchName = await generateImage(PrintingData().branchName());
      Uint8List? orderNo = await generateImage(PrintingData().orderNo());
      Uint8List? cashierNameAndPostingDate =
          await generateImage(PrintingData().cashierNameAndPostingDate());
      Uint8List? invoiceStatusAndOrderType =
          await generateImage(PrintingData().invoiceStatusAndOrderType());
      Uint8List? tableHeader =
          await generateImage(PrintingData().tableHeader());
      Uint8List? tableFotter =
          await generateImage(PrintingData().tableFotter());
      Uint8List? referenceNoAndPrintTime =
          await generateImage(PrintingData().referenceNoAndPrintTime());
      Uint8List? qr = await generateImage(PrintingData().qr());
      List<Widget> items = [
        PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        // PrintingData().tableItemRow(),
        PrintingData().tableItemRow(),
      ];
      List<Uint8List> products = [];
      for (var item in items) {
        Uint8List? productImg =
            await generateImage(PrintingData().tableItemRow());
        products.add(productImg!);
      }

      /// Start Printing
      if (logo != null) {
        bluetoothPrint.printImageBytes(logo);
      }
      if (companyImg != null) {
        bluetoothPrint.printImageBytes(companyImg);
      }

      if (branchName != null) {
        bluetoothPrint.printImageBytes(branchName);
      }
      if (orderNo != null) {
        bluetoothPrint.printImageBytes(orderNo);
      }
      if (cashierNameAndPostingDate != null) {
        bluetoothPrint.printImageBytes(cashierNameAndPostingDate);
      }
      if (invoiceStatusAndOrderType != null) {
        bluetoothPrint.printImageBytes(invoiceStatusAndOrderType);
      }

      if (tableHeader != null) {
        bluetoothPrint.printImageBytes(tableHeader);
      }

      for (var img in products) {
        bluetoothPrint.printImageBytes(img);
      }
      if (tableFotter != null) {
        bluetoothPrint.printImageBytes(tableFotter);
      }
      if (qr != null) {
        bluetoothPrint.printImageBytes(qr);
      }
      if (referenceNoAndPrintTime != null) {
        bluetoothPrint.printImageBytes(referenceNoAndPrintTime);
      }

      bluetoothPrint.printNewLine();
      bluetoothPrint.printNewLine();
      bluetoothPrint.printNewLine();
      await bluetoothPrint.disconnect();
      return;
    } catch (ex) {
      print("*******************");
      if (kDebugMode) {
        print("Error = $ex");
      }
      return;
    }
  }

  Future<Uint8List?> generateImage(Widget widget) async {
    return createImageFromWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(color: Colors.white, width: 280, child: widget),
        ),
        logicalSize: const Size(500, 500),
        imageSize: const Size(680, 680));
  }

  Future<void> checkBluetoothAndScanDevices() async {
    fb.FlutterBluePlus.adapterState.listen((state) async {
      if (state == fb.BluetoothAdapterState.on) {
        showToastError("Bluetooth on");
      } else {
        showToastError("Bluetooth off");
        await bluetoothPrint.isConnected.then((value) {
          if (value!) {
            bluetoothPrint.disconnect();
          }
        });
      }
    });
  }

  connectDevice(BluetoothDevice device) async {
    await bluetoothPrint.connect(device);
  }

  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      isScanning = true;
      showToastError("Start Scanning devices");
      devices = await bluetoothPrint.getBondedDevices();
      log('devices: $devices');
      showToastError("End Scanning devices");
      isScanning = false;
      return devices;
    } on PlatformException {
      isScanning = false;
      showToastError("Error no prepare devices founds");
      if (kDebugMode) {
        print("Error no prepare devices founds.");
      }
    }

    bluetoothPrint.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          showToastError("bluetooth device state: connected");
          break;
        case BlueThermalPrinter.DISCONNECTED:
          showToastError("bluetooth device state: disconnected");
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          showToastError("bluetooth device state: disconnect requested");
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          showToastError("bluetooth device state: bluetooth turning off");
          break;
        case BlueThermalPrinter.STATE_OFF:
          showToastError("bluetooth device state: bluetooth off");
          break;
        case BlueThermalPrinter.STATE_ON:
          showToastError("bluetooth device state: bluetooth on");
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          showToastError("bluetooth device state: bluetooth turning on");
          break;
        case BlueThermalPrinter.ERROR:
          showToastError("bluetooth device state: error");

          break;
        default:
          print(state);
          break;
      }
    });
    return devices;
  }
}
