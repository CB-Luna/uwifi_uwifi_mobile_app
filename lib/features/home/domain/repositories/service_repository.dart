import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/active_service.dart';

abstract class ServiceRepository {
  /// Obtiene los servicios activos del cliente
  ///
  /// Retorna [List<ActiveService>] si es exitoso, o [Failure] si ocurre un error
  Future<Either<Failure, List<ActiveService>>> getCustomerActiveServices(String customerId);
}
