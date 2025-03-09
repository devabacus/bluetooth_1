import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleScanResult {
  final String deviceName;
  final String deviceId;

  BleScanResult({required this.deviceId, required this.deviceName});
}

class BleCharacteristics {
  final String serviceUuid;
  final String uuid;
  final List<String> properties;
  final bool isNotifying;
  final List<int>? value;

  BleCharacteristics({
    required this.serviceUuid,
    required this.uuid,
    required this.properties,
    this.isNotifying = false,
    this.value
  });

  BleCharacteristics copyWithValue(List<int> newValue){
      return BleCharacteristics(
        serviceUuid: serviceUuid, 
        uuid: uuid, 
        properties: properties, 
        isNotifying: isNotifying, 
        value: newValue);
  }

  String? get valueAsString {
    if(value == null) return null;
    try {
      return String.fromCharCodes(value!);
    } catch (e) {
      return null;
    } 
  }


}

class BleManager {
  BleManager(this.log);

  final Function(String val) log;
  BluetoothDevice? _connectedDevice;
  Map<String, BluetoothService> discoveredServices = {};
  final Map<String, BleCharacteristics> characteristicsCache = {};
  final Map<String, StreamSubscription> notificationSubscribtions = {};



  final StreamController<List<BleScanResult>> _scanResultsController =
      StreamController.broadcast();
  final StreamController<BleCharacteristics> _characteristicNotificationController = StreamController.broadcast();
  final StreamController<List<String>> _serviceController =
      StreamController.broadcast();



  Stream<List<BleScanResult>> get scanResults => _scanResultsController.stream;
  Stream<List<String>> get serviceStream => _serviceController.stream;
  Stream<BleCharacteristics> get characteristicNotifications => _characteristicNotificationController.stream;

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

  Future<List<BleCharacteristics>?> getCharacteristics(
    String serviceUuid,
  ) async {
    final service = discoveredServices[serviceUuid];
    if (service == null) return null;

    final characteristics =
        service.characteristics
            .map(
              (char) {
                final bleChar = BleCharacteristics(
                serviceUuid: serviceUuid,
                uuid: char.uuid.toString(),
                properties: char.properties.toString().split(','),
                isNotifying: char.isNotifying,
              );

              characteristicsCache["$serviceUuid:${char.uuid}"] = bleChar;
              return bleChar;
              }
            )
            .toList();
    return characteristics;
  }

  Future<void> writeToCharacteristic({
    required String serviceUuid,
    required String characteristicUuid,
    required List<int> data,
    bool withresponse = true,
  }) async {
    if (_connectedDevice == null) {
      log("Устройство не подключено");
      return;
    }

    final service = discoveredServices[serviceUuid];
    if (service == null) {
      log('сервис не найден: $service');
      return;
    }

    try {
      final characteristic = service.characteristics.firstWhere(
        (char) => char.uuid.toString() == characteristicUuid,    
      );

      await characteristic.write(data, withoutResponse: !withresponse);
      log("Данные успешно записаны в характеристику: ${characteristic.uuid}");

    } catch (e) {
      log("Ошибка при записи в характеристику: $e");
    }
  }


  Future<void> subscribeToCharacteristic({
  required String serviceUuid,
  required String characteristicUuid,
}) async {
  if (_connectedDevice == null) {
    log("Устройство не подключено");
    return;
  }
  
  final String subscriptionKey = "$serviceUuid:$characteristicUuid";
  
  // Проверяем, не подписаны ли мы уже
  if (notificationSubscribtions.containsKey(subscriptionKey)) {
    log("Уже подписаны на характеристику: $characteristicUuid");
    return;
  }
  
  final service = discoveredServices[serviceUuid];
  if (service == null) {
    log("Сервис не найден: $serviceUuid");
    return;
  }
  
  try {
    final characteristic = service.characteristics.firstWhere(
      (char) => char.uuid.toString() == characteristicUuid
    );
    
    // Создаем подписку
    final subscription = characteristic.onValueReceived.listen((value) {
      // Получаем характеристику из кэша или создаем новую
      final cachedChar = characteristicsCache[subscriptionKey];
      final updatedChar = cachedChar != null 
          ? cachedChar.copyWithValue(value)
          : BleCharacteristics(
              serviceUuid: serviceUuid,
              uuid: characteristicUuid,
              properties: characteristic.properties.toString().split(','),
              isNotifying: true,
              value: value,
            );
      
      // Обновляем кэш
      characteristicsCache[subscriptionKey] = updatedChar;
      
      // Отправляем в поток
      _characteristicNotificationController.add(updatedChar);
    });
    
    // Сохраняем подписку
    notificationSubscribtions[subscriptionKey] = subscription;
    
    // Включаем уведомления на устройстве
    await characteristic.setNotifyValue(true);
    log("Подписка на характеристику активирована: $characteristicUuid");
  } catch (e) {
    log("Ошибка при подписке на характеристику: $e");
    rethrow;
  }
}

}

// Future<void> readCharateristics(String serviceUuid) async {
//   // final service = BluetoothDevice.;
// }
