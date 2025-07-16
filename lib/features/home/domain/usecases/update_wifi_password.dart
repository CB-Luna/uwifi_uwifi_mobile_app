import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/services/secure_storage_service.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/home/domain/entities/device_variable.dart';
import 'package:uwifiapp/features/home/domain/repositories/device_variable_repository.dart';

class UpdateWifiPassword implements UseCase<bool, UpdateWifiPasswordParams> {
  final DeviceVariableRepository repository;
  final SecureStorageService secureStorage;

  UpdateWifiPassword(this.repository, this.secureStorage);

  @override
  Future<Either<Failure, bool>> call(UpdateWifiPasswordParams params) async {
    // Determinar la variable a actualizar según el tipo de red
    String variableName;
    if (params.isNetwork24G) {
      variableName = 'Device.WiFi.SSID.1.Password';
    } else {
      variableName = 'Device.WiFi.SSID.3.Password';
    }

    final deviceVariable = DeviceVariable(
      variableName: variableName,
      value: params.newPassword,
    );

    final result = await repository.updateDeviceVariable(
      params.serialNumber,
      deviceVariable,
    );
    
    // Si la actualización fue exitosa, guardar la contraseña en almacenamiento seguro
    return result.fold(
      (failure) => Left(failure),
      (success) async {
        try {
          // Guardar el número de serie del gateway
          await secureStorage.saveGatewaySerialNumber(params.serialNumber);
          
          // Guardar la contraseña según el tipo de red
          if (params.isNetwork24G) {
            await secureStorage.saveWifi24GPassword(params.newPassword);
          } else {
            await secureStorage.saveWifi5GPassword(params.newPassword);
          }
          return Right(success);
        } catch (e) {
          // Si hay un error al guardar en almacenamiento seguro, seguimos considerando
          // que la actualización fue exitosa ya que el API respondió correctamente
          return Right(success);
        }
      },
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
