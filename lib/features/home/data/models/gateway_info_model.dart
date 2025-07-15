import '../../domain/entities/gateway_info.dart';

class GatewayInfoModel extends GatewayInfo {
  const GatewayInfoModel({
    required super.connectionStatus,
    required super.wifiName,
  });

  factory GatewayInfoModel.fromJson(Map<String, dynamic> json) {
    // Valores predeterminados
    String connectionStatus = 'Disconnected';
    String wifiName = 'U-wifi';

    // Extraer los valores de la respuesta
    if (json['results'] != null && json['results'] is List) {
      final results = json['results'] as List;
      
      // Buscar el estado de conexión
      final connectionStatusItem = results.firstWhere(
        (item) => item['name'] == 'Device.X_Web.MobileNetwork.ConnectionStatus.ConnectionStatus',
        orElse: () => {'value': 'Disconnected'},
      );
      
      // Buscar el nombre del WiFi
      final wifiNameItem = results.firstWhere(
        (item) => item['name'] == 'Device.WiFi.SSID.1.SSID',
        orElse: () => {'value': 'U-wifi'},
      );
      
      connectionStatus = connectionStatusItem['value'] ?? 'Disconnected';
      wifiName = wifiNameItem['value'] ?? 'U-wifi';
    }

    return GatewayInfoModel(
      connectionStatus: connectionStatus,
      wifiName: wifiName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connection_status': connectionStatus,
      'wifi_name': wifiName,
    };
  }
}
