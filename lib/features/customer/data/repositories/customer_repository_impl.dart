import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/customer_details.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../datasources/customer_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final CustomerLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CustomerDetails>> getCustomerDetails(int customerId) async {
    if (await networkInfo.isConnected) {
      try {
        final customerDetails = await remoteDataSource.getCustomerDetails(customerId);
        await localDataSource.cacheCustomerDetails(customerDetails);
        return Right(customerDetails);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localCustomerDetails = await localDataSource.getLastCustomerDetails();
        return Right(localCustomerDetails);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }
}
