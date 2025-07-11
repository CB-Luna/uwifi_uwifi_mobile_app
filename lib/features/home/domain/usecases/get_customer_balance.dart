import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/billing_repository.dart';

class GetCustomerBalance {
  final BillingRepository repository;

  GetCustomerBalance(this.repository);

  Future<Either<Failure, double>> call(String customerId) async {
    return await repository.getCustomerBalance(customerId);
  }
}
