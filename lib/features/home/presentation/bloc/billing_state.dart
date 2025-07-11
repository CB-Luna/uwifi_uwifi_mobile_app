import 'package:equatable/equatable.dart';
import '../../domain/entities/billing_period.dart';

abstract class BillingState extends Equatable {
  const BillingState();
  
  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {
  final BillingPeriod billingPeriod;
  final double? balance;

  const BillingLoaded({
    required this.billingPeriod,
    this.balance,
  });

  @override
  List<Object?> get props => [billingPeriod, balance];
  
  /// Crea una copia del estado actual con los campos especificados actualizados
  BillingLoaded copyWith({
    BillingPeriod? billingPeriod,
    double? balance,
  }) {
    return BillingLoaded(
      billingPeriod: billingPeriod ?? this.billingPeriod,
      balance: balance ?? this.balance,
    );
  }
}

class BillingError extends BillingState {
  final String message;

  const BillingError({required this.message});

  @override
  List<Object?> get props => [message];
}
