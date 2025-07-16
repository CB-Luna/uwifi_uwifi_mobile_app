import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';
import 'package:uwifiapp/features/home/domain/repositories/device_variable_repository.dart';

class UpdateWifiNetworkName
    implements UseCase<bool, UpdateWifiNetworkNameParams> {
  final DeviceVariableRepository repository;

  UpdateWifiNetworkName(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateWifiNetworkNameParams params) async {
    // Determinar la variable a actualizar según el tipo de red
    String variableName;
    if (params.isNetwork24G) {
      variableName = 'Device.WiFi.SSID.1.SSID';
    } else {
      variableName = 'Device.WiFi.SSID.3.SSID';
    }

    final deviceVariable = DeviceVariable(
      variableName: variableName,
      value: params.newName,
    );

    return await repository.updateDeviceVariable(
      params.serialNumber,
      deviceVariable,
    );
  }
}

class UpdateWifiNetworkNameParams extends Equatable {
  final String serialNumber;
  final String newName;
  final bool isNetwork24G; // true para 2.4GHz, false para 5GHz

  const UpdateWifiNetworkNameParams({
    required this.serialNumber,
    required this.newName,
    required this.isNetwork24G,
  });

  @override
  List<Object?> get props => [serialNumber, newName, isNetwork24G];
}
