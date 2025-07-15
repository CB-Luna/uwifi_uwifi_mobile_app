import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_bundle.dart';
import '../repositories/customer_bundle_repository.dart';

class GetCustomerBundle implements UseCase<List<CustomerBundle>, int> {
  final CustomerBundleRepository repository;

  GetCustomerBundle(this.repository);

  @override
  Future<Either<Failure, List<CustomerBundle>>> call(int params) async {
    return await repository.getCustomerBundle(params);
  }
}
