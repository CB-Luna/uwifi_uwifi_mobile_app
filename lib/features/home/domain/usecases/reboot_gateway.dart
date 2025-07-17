import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/gateway_operations_repository.dart';

class RebootGateway implements UseCase<bool, RebootGatewayParams> {
  final GatewayOperationsRepository repository;

  RebootGateway(this.repository);

  @override
  Future<Either<Failure, bool>> call(RebootGatewayParams params) async {
    return await repository.rebootGateway(params.serialNumber);
  }
}

class RebootGatewayParams extends Equatable {
  final String serialNumber;

  const RebootGatewayParams({required this.serialNumber});

  @override
  List<Object> get props => [serialNumber];
}
