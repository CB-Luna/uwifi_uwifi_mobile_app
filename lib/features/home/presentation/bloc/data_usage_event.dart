import 'package:equatable/equatable.dart';

abstract class DataUsageEvent extends Equatable {
  const DataUsageEvent();

  @override
  List<Object> get props => [];
}

class GetDataUsageEvent extends DataUsageEvent {
  final String customerId;

  const GetDataUsageEvent({required this.customerId});

  @override
  List<Object> get props => [customerId];
}

class ResetDataUsageEvent extends DataUsageEvent {}
