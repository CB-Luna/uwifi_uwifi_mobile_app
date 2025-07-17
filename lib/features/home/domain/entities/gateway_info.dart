import 'package:equatable/equatable.dart';

class ConnectedDevice extends Equatable {
  final String? macAddress;
  final String? name;
  final String? ipAddress;
  final String? connectionType; // Wired, WiFi

  const ConnectedDevice({
    this.macAddress,
    this.name,
    this.ipAddress,
    this.connectionType,
  });

  @override
  List<Object?> get props => [macAddress, name, ipAddress, connectionType];
}

class GatewayInfo extends Equatable {
  final String connectionStatus;
  final String wifiName;
  final String wifi24GName;
  final String wifi5GName;
  final String? serialNumber;
  final String? wifi24GPassword;
  final String? wifi5GPassword;
  final List<ConnectedDevice> devices24G;
  final List<ConnectedDevice> devices5G;

  const GatewayInfo({
    required this.connectionStatus,
    required this.wifiName,
    this.wifi24GName = '',
    this.wifi5GName = '',
    this.serialNumber,
    this.wifi24GPassword,
    this.wifi5GPassword,
    this.devices24G = const [],
    this.devices5G = const [],
  });

  /// Crea una copia de este objeto con los valores dados
  GatewayInfo copyWith({
    String? connectionStatus,
    String? wifiName,
    String? wifi24GName,
    String? wifi5GName,
    String? serialNumber,
    String? wifi24GPassword,
    String? wifi5GPassword,
    List<ConnectedDevice>? devices24G,
    List<ConnectedDevice>? devices5G,
  }) {
    return GatewayInfo(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      wifiName: wifiName ?? this.wifiName,
      wifi24GName: wifi24GName ?? this.wifi24GName,
      wifi5GName: wifi5GName ?? this.wifi5GName,
      serialNumber: serialNumber ?? this.serialNumber,
      wifi24GPassword: wifi24GPassword ?? this.wifi24GPassword,
      wifi5GPassword: wifi5GPassword ?? this.wifi5GPassword,
      devices24G: devices24G ?? this.devices24G,
      devices5G: devices5G ?? this.devices5G,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        wifiName,
        wifi24GName,
        wifi5GName,
        serialNumber,
        wifi24GPassword,
        wifi5GPassword,
        devices24G,
        devices5G,
      ];
}
