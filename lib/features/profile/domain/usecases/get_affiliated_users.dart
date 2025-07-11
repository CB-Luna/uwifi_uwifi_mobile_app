import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/affiliated_user.dart';
import '../repositories/wallet_repository.dart';

class GetAffiliatedUsers implements UseCase<List<AffiliatedUser>, String> {
  final WalletRepository repository;

  GetAffiliatedUsers(this.repository);

  @override
  Future<Either<Failure, List<AffiliatedUser>>> call(String customerId) async {
    return await repository.getAffiliatedUsers(customerId);
  }
}
