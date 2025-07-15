import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/affiliated_user.dart';
import '../../domain/entities/customer_points.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AffiliatedUser>>> getAffiliatedUsers(String customerId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.getAffiliatedUsers(customerId);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, CustomerPoints>> getCustomerPoints(String customerId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.getCustomerPoints(customerId);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
