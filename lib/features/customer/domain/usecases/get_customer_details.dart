import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_details.dart';
import '../repositories/customer_repository.dart';

class GetCustomerDetails implements UseCase<CustomerDetails, Params> {
  final CustomerRepository repository;

  GetCustomerDetails(this.repository);

  @override
  Future<Either<Failure, CustomerDetails>> call(Params params) async {
    return await repository.getCustomerDetails(params.customerId);
  }
}

class Params extends Equatable {
  final int customerId;

  const Params({required this.customerId});

  @override
  List<Object?> get props => [customerId];
}
