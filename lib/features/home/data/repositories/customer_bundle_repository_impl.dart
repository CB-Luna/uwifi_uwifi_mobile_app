import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/customer_bundle.dart';
import '../../domain/repositories/customer_bundle_repository.dart';
import '../datasources/customer_bundle_remote_data_source.dart';

class CustomerBundleRepositoryImpl implements CustomerBundleRepository {
  final CustomerBundleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  CustomerBundleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CustomerBundle>>> getCustomerBundle(
    int customerId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final customerBundle = await remoteDataSource.getCustomerBundle(
          customerId,
        );
        return Right(customerBundle);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
