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
  List<ScanResult> scanResults = [];
  List<BluetoothService>? services = [];
  List<BluetoothCharacteristic>? characteristics = [];

  Future<void> _requestPermission() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  // сохраняем список в scanResults
  Future<void> startScan(int scanSeconds) async {
    final scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    }, onError: (e) => print(e));

    FlutterBluePlus.cancelWhenScanComplete(scanSubscription);
    await FlutterBluePlus.startScan(timeout: Duration(seconds: scanSeconds));
  }

  Future<void> deviceConnect(BluetoothDevice device) async {
    await device.connect();
    final services = await device.discoverServices();
    // final characteristics = value;
    print('${device.advName} connected success');
    print('${services}');
  }

  @override
  void initState() {
    _requestPermission();
    startScan(60);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Доступные устройства"),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: Center(
        child:
            scanResults.isEmpty
                ? Text('Устройства не найдены')
                : ListView.builder(
                  itemCount: scanResults.length,
                  itemBuilder: (context, index) {
                    BluetoothDevice device = scanResults[index].device;
                    int rssi = scanResults[index].rssi;
                    String deviceName =
                        device.advName.isEmpty
                            ? 'Неизвестное устройство'
                            : device.advName;
                    return ListTile(
                      title: Text(deviceName),
                      subtitle: Text(device.remoteId.str),
                      trailing: Text(rssi.toString()),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BleDeviceServices(device),
                          ),
                        );
                      },
                    );
                  },
                ),
      ),
    );
  }
}

class BleDeviceServices extends StatefulWidget {
  final BluetoothDevice device;

  const BleDeviceServices(this.device, {super.key});

  @override
  State<BleDeviceServices> createState() => _BleDeviceServicesState();
}

class _BleDeviceServicesState extends State<BleDeviceServices> {
  List<BluetoothService> services = [];

  bool isLoading = true;

  Future<void> getDeviceServices() async {
    if (widget.device.connectionState != BluetoothConnectionState.connected) {
      await widget.device.connect();
    }

    await widget.device.connect();
    final discoveredServices = await widget.device.discoverServices();
    setState(() {
      services = discoveredServices;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDeviceServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Доступные устройства"),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : services.isEmpty
              ? Center(child: Text("Сервисы не найдены"))
              : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(services[index].serviceUuid.toString()),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => BleCharacteisticPage(
                                services[index].characteristics,
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}

class BleCharacteisticPage extends StatefulWidget {
  final List<BluetoothCharacteristic> bleCharacteristics;
  const BleCharacteisticPage(this.bleCharacteristics, {super.key});

  @override
  State<BleCharacteisticPage> createState() => _BleCharacteisticPageState();
}

class _BleCharacteisticPageState extends State<BleCharacteisticPage> {

    bool isNotifyActivated = false;    
    String charValue = "";

  Future<void> charSubscribe(BluetoothCharacteristic char) async {
      final subscr = char.onValueReceived.listen((val) {
        setState(() {
          charValue = String.fromCharCodes(val);
        });
      });

      await char.setNotifyValue(true);
    }
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Доступные устройства"),
        backgroundColor: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      body: 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(charValue,style: TextStyle(fontSize: 30)),
          SizedBox(height: 30,),
          Expanded(
            child: ListView.builder(
              itemCount: widget.bleCharacteristics.length,
              itemBuilder: (context, index) {
                final charachter = widget.bleCharacteristics[index];
                return ListTile(
                  title: Text(
                    charachter.characteristicUuid.toString(),
                  ),
                  subtitle: Text(charachter.properties.toString()),
                  trailing: Text(charachter.isNotifying.toString()),
                  onTap: () {
            
                    charSubscribe(charachter);
                    if(!isNotifyActivated){
                    isNotifyActivated = true;
                    } else {
                    isNotifyActivated = false;
                    charachter.setNotifyValue(false);
            
                    }
            
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
