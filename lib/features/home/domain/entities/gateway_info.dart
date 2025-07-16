import 'package:equatable/equatable.dart';

class GatewayInfo extends Equatable {
  final String connectionStatus;
  final String wifiName;
  final String wifi24GName;
  final String wifi5GName;
  final String? serialNumber;
  final String? wifi24GPassword;
  final String? wifi5GPassword;

  const GatewayInfo({
    required this.connectionStatus,
    required this.wifiName,
    this.wifi24GName = '',
    this.wifi5GName = '',
    this.serialNumber,
    this.wifi24GPassword,
    this.wifi5GPassword,
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
  }) {
    return GatewayInfo(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      wifiName: wifiName ?? this.wifiName,
      wifi24GName: wifi24GName ?? this.wifi24GName,
      wifi5GName: wifi5GName ?? this.wifi5GName,
      serialNumber: serialNumber ?? this.serialNumber,
      wifi24GPassword: wifi24GPassword ?? this.wifi24GPassword,
      wifi5GPassword: wifi5GPassword ?? this.wifi5GPassword,
    );
  }

  @override
  List<Object?> get props => [connectionStatus, wifiName, wifi24GName, wifi5GName, serialNumber, wifi24GPassword, wifi5GPassword];
}
