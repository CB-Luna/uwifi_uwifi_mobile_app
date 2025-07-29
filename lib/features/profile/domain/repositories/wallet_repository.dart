import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/affiliated_user.dart';
import '../entities/customer_points.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<AffiliatedUser>>> getAffiliatedUsers(String customerId);
  Future<Either<Failure, CustomerPoints>> getCustomerPoints(
    String customerId,
    {String? customerAfiliateId}
  );
}
