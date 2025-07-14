import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/traffic_data.dart';

abstract class TrafficRepository {
  /// Obtiene los datos de tráfico para un cliente en un rango de fechas
  ///
  /// Retorna una lista de [TrafficData] o un [Failure] en caso de error
  Future<Either<Failure, List<TrafficData>>> getTrafficInformation(
    String customerId,
    String startDate,
    String endDate,
  );
}
