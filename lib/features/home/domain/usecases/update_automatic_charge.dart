import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/billing_repository.dart';

class UpdateAutomaticChargeParams {
  final String customerId;
  final bool value;

  UpdateAutomaticChargeParams({
    required this.customerId,
    required this.value,
  });
}

class UpdateAutomaticCharge implements UseCase<bool, UpdateAutomaticChargeParams> {
  final BillingRepository repository;

  UpdateAutomaticCharge(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateAutomaticChargeParams params) async {
    return await repository.updateAutomaticCharge(
      customerId: params.customerId,
      value: params.value,
    );
  }
}
