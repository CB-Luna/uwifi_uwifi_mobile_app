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
