import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/gateway_info.dart';
import '../../domain/repositories/gateway_info_repository.dart';
import '../datasources/gateway_info_remote_data_source.dart';

class GatewayInfoRepositoryImpl implements GatewayInfoRepository {
  final GatewayInfoRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GatewayInfoRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, GatewayInfo>> getGatewayInfo(String serialNumber) async {
    if (await networkInfo.isConnected) {
      try {
        final gatewayInfo = await remoteDataSource.getGatewayInfo(serialNumber);
        return Right(gatewayInfo);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
  }
}
