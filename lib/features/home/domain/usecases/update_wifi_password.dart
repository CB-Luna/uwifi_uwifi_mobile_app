import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';
import 'package:uwifiapp/features/home/domain/repositories/device_variable_repository.dart';

class UpdateWifiPassword implements UseCase<bool, UpdateWifiPasswordParams> {
  final DeviceVariableRepository repository;

  UpdateWifiPassword(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateWifiPasswordParams params) async {
    // Determinar la variable a actualizar según el tipo de red
    String variableName;
    if (params.isNetwork24G) {
      variableName = 'Device.WiFi.AccessPoint.1.Security.KeyPassphrase';
    } else {
      variableName = 'Device.WiFi.AccessPoint.3.Security.KeyPassphrase';
    }

    final deviceVariable = DeviceVariable(
      variableName: variableName,
      value: params.newPassword,
    );

    return await repository.updateDeviceVariable(
      params.serialNumber,
      deviceVariable,
    );
  }
}

class UpdateWifiPasswordParams extends Equatable {
  final String serialNumber;
  final String newPassword;
  final bool isNetwork24G; // true para 2.4GHz, false para 5GHz

  const UpdateWifiPasswordParams({
    required this.serialNumber,
    required this.newPassword,
    required this.isNetwork24G,
  });

  @override
  List<Object?> get props => [serialNumber, newPassword, isNetwork24G];
}
