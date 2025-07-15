import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/customer_points.dart';
import '../repositories/wallet_repository.dart';

class GetCustomerPoints implements UseCase<CustomerPoints, String> {
  final WalletRepository repository;

  GetCustomerPoints(this.repository);

  @override
  Future<Either<Failure, CustomerPoints>> call(String params) async {
    return await repository.getCustomerPoints(params);
  }
}
