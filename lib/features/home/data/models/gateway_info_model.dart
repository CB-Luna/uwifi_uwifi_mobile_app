import '../../domain/entities/gateway_info.dart';

class GatewayInfoModel extends GatewayInfo {
  const GatewayInfoModel({
    required super.connectionStatus,
    required super.wifiName,
    required super.wifi24GName,
    required super.wifi5GName,
  });

  factory GatewayInfoModel.fromJson(Map<String, dynamic> json) {
    // Valores predeterminados
    String connectionStatus = 'Disconnected';
    String wifiName = 'U-wifi';
    String wifi24GName = 'U-wifi 2.4G';
    String wifi5GName = 'U-wifi 5G';

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
    }

    return GatewayInfoModel(
      connectionStatus: connectionStatus,
      wifiName: wifiName,
      wifi24GName: wifi24GName,
      wifi5GName: wifi5GName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_status': connectionStatus,
      'wifi_name': wifiName,
      'wifi_24g_name': wifi24GName,
      'wifi_5g_name': wifi5GName,
    };
  }
}
