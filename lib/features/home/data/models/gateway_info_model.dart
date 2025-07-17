import 'dart:convert';

import '../../domain/entities/gateway_info.dart';

class GatewayInfoModel extends GatewayInfo {
  const GatewayInfoModel({
    required super.connectionStatus,
    required super.wifiName,
    required super.wifi24GName,
    required super.wifi5GName,
    super.serialNumber,
    super.wifi24GPassword,
    super.wifi5GPassword,
    super.devices24G,
    super.devices5G,
  });

  factory GatewayInfoModel.fromJson(Map<String, dynamic> json, {String? serialNumber}) {
    // Valores predeterminados
    String connectionStatus = 'Disconnected';
    String wifiName = 'U-wifi';
    String wifi24GName = 'U-wifi 2.4G';
    String wifi5GName = 'U-wifi 5G';
    String? wifi24GPassword;
    String? wifi5GPassword;
    List<ConnectedDevice> devices24G = [];
    List<ConnectedDevice> devices5G = [];

    // Extraer los valores de la respuesta
    if (json['results'] != null && json['results'] is List) {
      final results = json['results'] as List;
      
      // Buscar el estado de conexión
      final connectionStatusItem = results.firstWhere(
        (item) => item['name'] == 'Device.X_Web.MobileNetwork.ConnectionStatus.ConnectionStatus',
        orElse: () => {'value': 'Disconnected'},
      );
      
      // Buscar el nombre del WiFi principal (usado para mostrar en la tarjeta de conexión)
      final wifiNameItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.1.SSID',
        orElse: () => {'value': 'U-wifi'},
      );
      
      // Buscar el nombre del WiFi 2.4 GHz
      final wifi24GItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.1.SSID',
        orElse: () => {'value': 'U-wifi 2.4G'},
      );
      
      // Buscar el nombre del WiFi 5 GHz
      final wifi5GItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.3.SSID',
        orElse: () => {'value': 'U-wifi 5G'},
      );
      
      connectionStatus = connectionStatusItem['value'] ?? 'Disconnected';
      wifiName = wifiNameItem['value'] ?? 'U-wifi';
      wifi24GName = wifi24GItem['value'] ?? 'U-wifi 2.4G';
      wifi5GName = wifi5GItem['value'] ?? 'U-wifi 5G';
      
      // Buscar las contraseñas de WiFi
      final wifi24GPasswordItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.1.Password',
        orElse: () => {'value': null},
      );
      
      final wifi5GPasswordItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.3.Password',
        orElse: () => {'value': null},
      );
      
      wifi24GPassword = wifi24GPasswordItem['value'];
      wifi5GPassword = wifi5GPasswordItem['value'];
      
      // Buscar información de dispositivos conectados a la red de 2.4GHz
      final devices24GItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.Accesspoint.1.AssociatedDevice.',
        orElse: () => {'value': '', 'type': 'table'},
      );
      
      // Buscar información de dispositivos conectados a la red de 5GHz
      final devices5GItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.Accesspoint.3.AssociatedDevice.',
        orElse: () => {'value': '', 'type': 'table'},
      );
      
      // Procesar dispositivos conectados a 2.4GHz
      if (devices24GItem['type'] == 'table' && devices24GItem['value'] != null) {
        // Aquí procesaríamos la información de los dispositivos conectados
        // Por ahora, como no tenemos la estructura exacta, creamos dispositivos de ejemplo
        // En una implementación real, esto vendría de la API
        try {
          if (devices24GItem['value'].toString().isNotEmpty) {
            // Intentar parsear como JSON si es posible
            final devicesData = devices24GItem['value'];
            if (devicesData is List) {
              devices24G = _parseConnectedDevices(devicesData);
            } else if (devicesData is String && devicesData.isNotEmpty) {
              // Si es un string, intentar convertirlo a JSON
              try {
                final List<dynamic> parsedData = jsonDecode(devicesData);
                devices24G = _parseConnectedDevices(parsedData);
              } catch (e) {
                // Si no se puede parsear, dejamos la lista vacía
              }
            }
          }
        } catch (e) {
          // En caso de error, dejamos la lista vacía
        }
      }
      
      // Procesar dispositivos conectados a 5GHz
      if (devices5GItem['type'] == 'table' && devices5GItem['value'] != null) {
        try {
          if (devices5GItem['value'].toString().isNotEmpty) {
            // Intentar parsear como JSON si es posible
            final devicesData = devices5GItem['value'];
            if (devicesData is List) {
              devices5G = _parseConnectedDevices(devicesData);
            } else if (devicesData is String && devicesData.isNotEmpty) {
              // Si es un string, intentar convertirlo a JSON
              try {
                final List<dynamic> parsedData = jsonDecode(devicesData);
                devices5G = _parseConnectedDevices(parsedData);
              } catch (e) {
                // Si no se puede parsear, dejamos la lista vacía
              }
            }
          }
        } catch (e) {
          // En caso de error, dejamos la lista vacía
        }
      }
    }

    return GatewayInfoModel(
      connectionStatus: connectionStatus,
      wifiName: wifiName,
      wifi24GName: wifi24GName,
      wifi5GName: wifi5GName,
      serialNumber: serialNumber,
      wifi24GPassword: wifi24GPassword,
      wifi5GPassword: wifi5GPassword,
      devices24G: devices24G,
      devices5G: devices5G,
    );
  }
  
  // Método auxiliar para parsear dispositivos conectados
  static List<ConnectedDevice> _parseConnectedDevices(List<dynamic> devicesData) {
    final List<ConnectedDevice> devices = [];
    
    for (var device in devicesData) {
      try {
        devices.add(ConnectedDevice(
          macAddress: device['mac_address'] ?? device['macAddress'],
          name: device['name'] ?? device['hostname'] ?? 'Unknown Device',
          ipAddress: device['ip_address'] ?? device['ipAddress'],
          connectionType: 'WiFi',
        ));
      } catch (e) {
        // Si hay un error al parsear un dispositivo, lo ignoramos
      }
    }
    
    return devices;
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_status': connectionStatus,
      'wifi_name': wifiName,
      'wifi_24g_name': wifi24GName,
      'wifi_5g_name': wifi5GName,
      'serial_number': serialNumber,
      'wifi_24g_password': wifi24GPassword,
      'wifi_5g_password': wifi5GPassword,
      'devices_24g': devices24G.map((device) => {
        'mac_address': device.macAddress,
        'name': device.name,
        'ip_address': device.ipAddress,
        'connection_type': device.connectionType,
      }).toList(),
      'devices_5g': devices5G.map((device) => {
        'mac_address': device.macAddress,
        'name': device.name,
        'ip_address': device.ipAddress,
        'connection_type': device.connectionType,
      }).toList(),
    };
  }
}
