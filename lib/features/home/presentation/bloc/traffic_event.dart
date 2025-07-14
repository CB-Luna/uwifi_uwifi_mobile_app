import 'package:equatable/equatable.dart';

abstract class TrafficEvent extends Equatable {
  const TrafficEvent();

  @override
  List<Object> get props => [];
}

class GetTrafficInformationEvent extends TrafficEvent {
  final String customerId;
  final String startDate;
  final String endDate;

  const GetTrafficInformationEvent({
    required this.customerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [customerId, startDate, endDate];
}
