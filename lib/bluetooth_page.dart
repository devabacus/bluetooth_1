import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
        final result = results.first;
        // print('${result.device.advName} : ${result.advertisementData}');
      }
    }, onError: (e) => print(e));

    FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
    // await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on);

    await FlutterBluePlus.startScan(timeout: Duration(seconds: scanSeconds));
  }

  Future<void> deviceConnect(BluetoothDevice device) async {
    await device.connect();
    print('${device.advName} connected success');
    print('${device.servicesList}');
  }

  @override
  void initState() {
    _requestPermission();
    startScan(10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: FlutterBluePlus.onScanResults,
          builder: (context, snapshot) {

            


            if (snapshot.hasError) {
              return Text('ошибка ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Устройства не найдены');
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String deviceName = snapshot.data![index].device.advName;

                if (deviceName.isEmpty) {
                  deviceName = snapshot.data![index].device.remoteId.str;
                }

                return ListTile(
                  title: Text(deviceName),
                  onTap: () => deviceConnect(snapshot.data![index].device),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
