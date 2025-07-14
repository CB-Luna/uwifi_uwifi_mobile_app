import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/data_usage.dart';
import '../repositories/gateway_repository.dart';

class GetDataUsage implements UseCase<DataUsage, CustomerIdParams> {
  final GatewayRepository repository;

  GetDataUsage(this.repository);

  @override
  Future<Either<Failure, DataUsage>> call(CustomerIdParams params) async {
    return await repository.getDataUsage(params.customerId);
  }
}

class CustomerIdParams extends Equatable {
  final String customerId;

  const CustomerIdParams({required this.customerId});

  @override
  List<Object> get props => [customerId];
}
