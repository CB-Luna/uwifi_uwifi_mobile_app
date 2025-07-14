import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/active_service_model.dart';

abstract class ServiceRemoteDataSource {
  /// Obtiene los servicios activos del cliente desde la API
  ///
  /// Llama a la función RPC 'get_customer_active_services'
  /// Retorna [List<ActiveServiceModel>] si es exitoso, o [Failure] si ocurre un error
  Future<Either<Failure, List<ActiveServiceModel>>> getCustomerActiveServices(String customerId);
}
