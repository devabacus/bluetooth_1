import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanResult {
  final String deviceName;
  final String deviceId;

  BleScanResult({required this.deviceId, required this.deviceName});
}

class BleManager {
  final Function(String val) log;
  BleManager(this.log);

  final StreamController<List<BleScanResult>> _scanResultsController =
      StreamController.broadcast();

  final StreamController<List<String>> _serviceController =
      StreamController.broadcast();

  Stream<List<BleScanResult>> get scanResults => _scanResultsController.stream;

  Stream<List<String>> get serviceStream => _serviceController.stream;

  Future<void> _requestPermission() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  Future<void> startScan() async {
    FlutterBluePlus.onScanResults.listen((results) {
      final transformedResutls =
          results
              .map(
                (r) => BleScanResult(
                  deviceId: r.device.remoteId.toString(),
                  deviceName:
                      r.advertisementData.advName.isEmpty
                          ? "Неизвестное устройство"
                          : r.advertisementData.advName,
                ),
              )
              .toList();

      _scanResultsController.add(transformedResutls);
    }, onError: (e) => log(e));
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> bleConnect(String deviceId) async {
    var device = BluetoothDevice.fromId(deviceId);
    await device.connect();
    var services = await device.discoverServices();
    _serviceController.add(
      services.map((bleService) => bleService.uuid.toString()).toList(),
    );
  }

  void dispose() {
    _scanResultsController.close();
    _serviceController.close();
  }
}

// Future<void> readCharateristics(String serviceUuid) async {
//   // final service = BluetoothDevice.;
// }

Future<BluetoothService?> getService(String deviceId, String serviceUuid) async {
  final device = BluetoothDevice.fromId(deviceId);
  var services = await device.discoverServices();
  try {
    return services.firstWhere(
      (service) => service.uuid.toString() == serviceUuid,
    );
  } catch (e) {
    return null;
  }
}

Future<List<String>?> getCharacteristics(String deviceId, String serviceUuid) async{
  final service = await getService(deviceId, serviceUuid);
  final charsUuid = service?.characteristics.map((char) => char.characteristicUuid.toString()).toList();

  return charsUuid;
}
