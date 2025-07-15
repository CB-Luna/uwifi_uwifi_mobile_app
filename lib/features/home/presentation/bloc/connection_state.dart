import 'package:equatable/equatable.dart';

import '../../domain/entities/gateway_info.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

class ConnectionInitial extends ConnectionState {
  const ConnectionInitial();
}

class ConnectionLoading extends ConnectionState {
  final GatewayInfo? previousInfo;

  const ConnectionLoading({this.previousInfo});

  @override
  List<Object?> get props => [previousInfo];
}

class ConnectionLoaded extends ConnectionState {
  final GatewayInfo gatewayInfo;

  const ConnectionLoaded({required this.gatewayInfo});

  @override
  List<Object?> get props => [gatewayInfo];
}

class ConnectionError extends ConnectionState {
  final String message;

  const ConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}
