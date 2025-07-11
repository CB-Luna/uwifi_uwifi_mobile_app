import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/affiliated_user.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<AffiliatedUser>>> getAffiliatedUsers(String customerId);
}
