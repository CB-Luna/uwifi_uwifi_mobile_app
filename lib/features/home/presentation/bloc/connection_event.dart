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
