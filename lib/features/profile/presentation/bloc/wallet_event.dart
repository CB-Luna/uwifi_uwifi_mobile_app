import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetAffiliatedUsersEvent extends WalletEvent {
  final String customerId;

  const GetAffiliatedUsersEvent({required this.customerId});

  @override
  List<Object?> get props => [customerId];
}

class GetCustomerPointsEvent extends WalletEvent {
  final String customerId;
  final String? customerAfiliateId;

  const GetCustomerPointsEvent({
    required this.customerId,
    this.customerAfiliateId,
  });

  @override
  List<Object?> get props => [customerId, customerAfiliateId];
}
