import 'package:equatable/equatable.dart';

import '../../domain/entities/traffic_data.dart';

abstract class TrafficState extends Equatable {
  const TrafficState();

  @override
  List<Object> get props => [];
}

class TrafficInitial extends TrafficState {}

class TrafficLoading extends TrafficState {}

class TrafficLoaded extends TrafficState {
  final List<TrafficData> trafficData;

  const TrafficLoaded({required this.trafficData});

  @override
  List<Object> get props => [trafficData];
}

class TrafficError extends TrafficState {
  final String message;

  const TrafficError({required this.message});

  @override
  List<Object> get props => [message];
}
