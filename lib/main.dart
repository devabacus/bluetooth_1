import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BluetoothPage());
  }
}

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
 
  Future<void> _requestPermission() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<void> startScan(int scanSeconds) async {
    final scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        final result = results.last;
        print('${result.device.advName} : ${result.advertisementData}');
      }
    }, onError: (e) => print(e));

    FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
    // await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on);

    await FlutterBluePlus.startScan(timeout: Duration(seconds: scanSeconds));
  }

  @override
  void initState() {
    _requestPermission();
    startScan(10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("My App")));
  }
}
