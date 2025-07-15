import 'package:equatable/equatable.dart';

class GatewayInfo extends Equatable {
  final String connectionStatus;
  final String wifiName;
  final String wifi24GName;
  final String wifi5GName;

  const GatewayInfo({
    required this.connectionStatus,
    required this.wifiName,
    this.wifi24GName = '',
    this.wifi5GName = '',
  });

  @override
  List<Object?> get props => [connectionStatus, wifiName, wifi24GName, wifi5GName];
}
