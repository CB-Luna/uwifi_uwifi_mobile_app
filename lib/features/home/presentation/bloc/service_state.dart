import 'package:equatable/equatable.dart';

import '../../domain/entities/active_service.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ActiveService> services;

  const ServiceLoaded({required this.services});

  @override
  List<Object> get props => [services];
}

class ServiceError extends ServiceState {
  final String message;

  const ServiceError({required this.message});

  @override
  List<Object> get props => [message];
}
