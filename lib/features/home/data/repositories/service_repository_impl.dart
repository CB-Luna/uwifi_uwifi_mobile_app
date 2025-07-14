import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/active_service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_data_source.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ActiveService>>> getCustomerActiveServices(
    String customerId,
  ) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.getCustomerActiveServices(customerId);
    } else {
      return const Left(NetworkFailure());
    }
  }
}
