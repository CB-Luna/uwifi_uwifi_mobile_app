import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';

abstract class DeviceVariableRepository {
  /// Updates a device variable for the specified serial number
  /// Returns [bool] indicating success or [Failure] if unsuccessful
  Future<Either<Failure, bool>> updateDeviceVariable(
    String serialNumber,
    DeviceVariable variable,
  );
}
