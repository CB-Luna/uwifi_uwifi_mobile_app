import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object> get props => [];
}

class GetConnectionInfoEvent extends ConnectionEvent {
  final int customerId;

  const GetConnectionInfoEvent(this.customerId);

  @override
  List<Object> get props => [customerId];
}

class UpdateWifiNetworkNameEvent extends ConnectionEvent {
  final String serialNumber;
  final String newName;
  final bool isNetwork24G; // true para 2.4GHz, false para 5GHz

  const UpdateWifiNetworkNameEvent({
    required this.serialNumber,
    required this.newName,
    required this.isNetwork24G,
  });

  @override
  List<Object> get props => [serialNumber, newName, isNetwork24G];
}

class UpdateWifiPasswordEvent extends ConnectionEvent {
  final String serialNumber;
  final String newPassword;
  final bool isNetwork24G; // true para 2.4GHz, false para 5GHz

  const UpdateWifiPasswordEvent({
    required this.serialNumber,
    required this.newPassword,
    required this.isNetwork24G,
  });

  @override
  List<Object> get props => [serialNumber, newPassword, isNetwork24G];
}
