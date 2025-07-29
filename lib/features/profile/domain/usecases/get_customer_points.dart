import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_points.dart';
import '../repositories/wallet_repository.dart';

class GetCustomerPointsParams extends Equatable {
  final String customerId;
  final String? customerAfiliateId;

  const GetCustomerPointsParams({
    required this.customerId,
    this.customerAfiliateId,
  });

  @override
  List<Object?> get props => [customerId, customerAfiliateId];
}

class GetCustomerPoints implements UseCase<CustomerPoints, GetCustomerPointsParams> {
  final WalletRepository repository;

  GetCustomerPoints(this.repository);

  @override
  Future<Either<Failure, CustomerPoints>> call(GetCustomerPointsParams params) async {
    return await repository.getCustomerPoints(
      params.customerId,
      customerAfiliateId: params.customerAfiliateId,
    );
  }
}
