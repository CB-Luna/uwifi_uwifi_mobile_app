import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/gateway_operations_repository.dart';
import '../datasources/gateway_operations_remote_data_source.dart';

class GatewayOperationsRepositoryImpl implements GatewayOperationsRepository {
  final GatewayOperationsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GatewayOperationsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> rebootGateway(String serialNumber) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.rebootGateway(serialNumber);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
