import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/billing_period.dart';
import '../repositories/billing_repository.dart';

class GetCurrentBillingPeriod {
  final BillingRepository repository;

  GetCurrentBillingPeriod(this.repository);

  Future<Either<Failure, BillingPeriod>> call(String customerId) async {
    return await repository.getCurrentBillingPeriod(customerId);
  }
}
