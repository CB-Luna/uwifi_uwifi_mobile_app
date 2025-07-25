import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/affiliate_repository.dart';
import '../datasources/affiliate_remote_data_source.dart';

class AffiliateRepositoryImpl implements AffiliateRepository {
  final AffiliateRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AffiliateRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> sendAffiliateInvitation({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required int customerId,
  }) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.sendAffiliateInvitation(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        customerId: customerId,
      );
    } else {
      return Left(NetworkFailure());
    }
  }
}
