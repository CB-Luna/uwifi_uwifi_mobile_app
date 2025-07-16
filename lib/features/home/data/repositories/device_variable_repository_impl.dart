import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/exceptions.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/network/network_info.dart';
import 'package:uwifiapp/features/home/data/datasources/device_variable_remote_data_source.dart';
import 'package:uwifiapp/features/home/data/models/device_variable_model.dart';
import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';
import 'package:uwifiapp/features/home/domain/repositories/device_variable_repository.dart';

class DeviceVariableRepositoryImpl implements DeviceVariableRepository {
  final DeviceVariableRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeviceVariableRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> updateDeviceVariable(
    String serialNumber,
    DeviceVariable variable,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final deviceVariableModel = DeviceVariableModel(
          variableName: variable.variableName,
          value: variable.value,
        );

        final result = await remoteDataSource.updateDeviceVariable(
          serialNumber,
          deviceVariableModel,
        );

        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
