import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanResult {
  final String deviceName;
  final String deviceId;

  BleScanResult({required this.deviceId, required this.deviceName});
}

class BleCharacteristics {
  final String uuid;
  final List<String> properties;
  final bool isNotifying;

  BleCharacteristics({
    required this.uuid,
    required this.properties,
    this.isNotifying = false,
  });
}

class BleManager {
  BleManager(this.log);

  final Function(String val) log;
  BluetoothDevice? _connectedDevice;
  Map<String, BluetoothService> discoveredServices = {};

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
    if (_connectedDevice?.remoteId.toString() == deviceId) {
      log("Устройство уже подключено");
      return;
    }

    var device = BluetoothDevice.fromId(deviceId);
    await device.connect();
    _connectedDevice = device;

    await discoverServices();
  }

  Future<List<String>> discoverServices() async {
    if (_connectedDevice == null) {
      log("Устройство не подключено");
      return [];
    }

    List<String> serviceUuids = [];

    var services = await _connectedDevice!.discoverServices();
    discoveredServices.clear();

    for (var service in services) {
      String uuid = service.uuid.toString();
      discoveredServices[uuid] = service;
      serviceUuids.add(uuid);
    }
    _serviceController.add(serviceUuids);
    return serviceUuids;
  }

  void dispose() {
    _scanResultsController.close();
    _serviceController.close();
  }

  Future<BluetoothService?> getService(
    String deviceId,
    String serviceUuid,
  ) async {
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

  Future<List<BleCharacteristics>?> getCharacteristics(String serviceUuid) async {
    final service = discoveredServices[serviceUuid];
    if (service == null) return null;

    final characteristics = service.characteristics.map(
      (char) => BleCharacteristics(
        uuid: char.uuid.toString(),
        properties: char.properties.toString().split(','),
        isNotifying: char.isNotifying,
      ),
    ).toList();

    return characteristics;
  }
}

// Future<void> readCharateristics(String serviceUuid) async {
//   // final service = BluetoothDevice.;
// }
