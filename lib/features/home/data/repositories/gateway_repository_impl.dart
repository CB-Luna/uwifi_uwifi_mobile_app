import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/data_usage.dart';
import '../../domain/repositories/gateway_repository.dart';
import '../datasources/gateway_remote_data_source.dart';

class GatewayRepositoryImpl implements GatewayRepository {
  final GatewayRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GatewayRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DataUsage>> getDataUsage(String customerId) async {
    if (await networkInfo.isConnected) {
      try {
        final dataUsage = await remoteDataSource.getDataUsage(customerId);
        return Right(dataUsage);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a Internet'));
    }
  }
}
