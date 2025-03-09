import 'dart:async';

import 'package:bluetooth_1/ble_manager.dart';
import 'package:flutter/material.dart';

class BluetoothPage2 extends StatefulWidget {
  const BluetoothPage2({super.key});

  @override
  State<BluetoothPage2> createState() => _BluetoothPage2State();
}

class _BluetoothPage2State extends State<BluetoothPage2> {
  final bleManager = BleManager(print);
  final List<BleScanResult> _scanResults = [];
  String deviceId = "";
  
  StreamSubscription<List<BleScanResult>>? _scanSubscription;
  StreamSubscription<List<String>>? _serviceSubscription;
  
  
// DA:20:24:1F:C3:01
// 15a0737e-446b-4ae2-aa25-1057f8ac05c7


  @override
  void initState() {

    _serviceSubscription = bleManager.serviceStream.listen((servicesUuid){
      print('$servicesUuid serviceUuid');
      const nordicUartServiceUuid = '15a0737e-446b-4ae2-aa25-1057f8ac05c7';

      if (servicesUuid.contains(nordicUartServiceUuid)) {
        final chars = bleManager.getCharacteristics(nordicUartServiceUuid);
        // print('ivan');

        print(chars);

      }
      
    });


    _scanSubscription = bleManager.scanResults.listen((results){
      // print(results);
      final _deviceId = results.first.deviceId;
      if (_deviceId == 'DA:20:24:1F:C3:01') {
        deviceId = _deviceId;
        bleManager.bleConnect(deviceId);
      }
      




    });




    bleManager.startScan();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("BluetoothPage", style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
