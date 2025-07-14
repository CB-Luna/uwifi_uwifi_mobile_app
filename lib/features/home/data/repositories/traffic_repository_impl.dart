import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/traffic_data.dart';
import '../../domain/repositories/traffic_repository.dart';
import '../datasources/traffic_remote_data_source.dart';

class TrafficRepositoryImpl implements TrafficRepository {
  final TrafficRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TrafficRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TrafficData>>> getTrafficInformation(
    String customerId,
    String startDate,
    String endDate,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final trafficData = await remoteDataSource.getTrafficInformation(
          customerId,
          startDate,
          endDate,
        );
        return Right(trafficData);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
