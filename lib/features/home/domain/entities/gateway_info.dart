import 'package:equatable/equatable.dart';

class GatewayInfo extends Equatable {
  final String connectionStatus;
  final String wifiName;

  const GatewayInfo({
    required this.connectionStatus,
    required this.wifiName,
  });

  @override
  List<Object?> get props => [connectionStatus, wifiName];
}
