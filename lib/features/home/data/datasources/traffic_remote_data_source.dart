import '../models/traffic_data_model.dart';

abstract class TrafficRemoteDataSource {
  /// Llama al endpoint get_traffic_information para obtener los datos de tráfico
  ///
  /// Lanza [ServerException] en caso de error
  Future<List<TrafficDataModel>> getTrafficInformation(
    String customerId,
    String startDate,
    String endDate,
  );
}
