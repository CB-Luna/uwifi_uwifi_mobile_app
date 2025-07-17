import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class GatewayOperationsRepository {
  /// Reinicia el gateway con el número de serie proporcionado
  /// Retorna [Either<Failure, bool>] indicando éxito o fracaso
  Future<Either<Failure, bool>> rebootGateway(String serialNumber);
}
