import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/active_service.dart';
import '../repositories/service_repository.dart';

class GetCustomerActiveServices {
  final ServiceRepository repository;

  GetCustomerActiveServices(this.repository);

  Future<Either<Failure, List<ActiveService>>> call(String customerId) async {
    return await repository.getCustomerActiveServices(customerId);
  }
}
