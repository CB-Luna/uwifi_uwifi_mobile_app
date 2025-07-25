import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import '../repositories/billing_repository.dart';

class CreateManualBilling implements UseCase<bool, CreateManualBillingParams> {
  final BillingRepository repository;

  CreateManualBilling(this.repository);

  @override
  Future<Either<Failure, bool>> call(CreateManualBillingParams params) async {
    return await repository.createManualBilling(
      customerId: params.customerId,
      billingDate: params.billingDate,
      discount: params.discount,
      autoPayment: params.autoPayment,
    );
  }
}

class CreateManualBillingParams extends Equatable {
  final int customerId;
  final String billingDate;
  final double discount;
  final bool autoPayment;

  const CreateManualBillingParams({
    required this.customerId,
    required this.billingDate,
    required this.discount,
    required this.autoPayment,
  });

  @override
  List<Object> get props => [customerId, billingDate, discount, autoPayment];
}
