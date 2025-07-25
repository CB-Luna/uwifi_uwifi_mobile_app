import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

abstract class AffiliateRepository {
  /// Sends an invitation to a new affiliate user
  /// 
  /// Returns [Right(true)] if successful, [Left(Failure)] otherwise
  Future<Either<Failure, bool>> sendAffiliateInvitation({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required int customerId,
  });
}
