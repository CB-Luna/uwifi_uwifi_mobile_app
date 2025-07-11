import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/affiliated_user_model.dart';

abstract class WalletRemoteDataSource {
  Future<Either<Failure, List<AffiliatedUserModel>>> getAffiliatedUsers(String customerId);
}
