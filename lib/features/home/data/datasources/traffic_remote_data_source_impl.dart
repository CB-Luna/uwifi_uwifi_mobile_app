import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/traffic_data_model.dart';
import 'traffic_remote_data_source.dart';

class TrafficRemoteDataSourceImpl implements TrafficRemoteDataSource {
  final SupabaseClient supabaseClient;

  TrafficRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TrafficDataModel>> getTrafficInformation(
    String customerId,
    String startDate,
    String endDate,
  ) async {
    try {
      AppLogger.navInfo(
        'Obteniendo información de tráfico para customerId: $customerId, '
        'desde $startDate hasta $endDate',
      );

      // Preparar el cuerpo de la solicitud
      final requestBody = {
        'customerid': customerId,
        'start_date': startDate,
        'end_date': endDate,
      };

      // Realizar la solicitud a la función RPC de Supabase
      AppLogger.navInfo(
        'Enviando solicitud a get_traffic_information con params: $requestBody',
      );
      final response = await supabaseClient.rpc(
        'get_traffic_information',
        params: requestBody,
      );
      AppLogger.navInfo('Respuesta recibida: $response');

      if (response == null) {
        AppLogger.navError(
          'Error al obtener información de tráfico: respuesta nula',
        );
        throw ServerException('Error al obtener información de tráfico');
      }

      // Verificar si la respuesta es una lista
      if (response is! List) {
        AppLogger.navError(
          'Error al obtener información de tráfico: formato incorrecto',
        );
        throw ServerException('Formato de respuesta incorrecto');
      }

      // Convertir la respuesta a una lista de modelos
      final trafficDataList = (response)
          .map(
            (item) => TrafficDataModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      AppLogger.navInfo(
        'Información de tráfico obtenida con éxito: ${trafficDataList.length} registros',
      );

      return trafficDataList;
    } catch (e) {
      AppLogger.navError('Error al obtener información de tráfico: $e');
      throw ServerException(e.toString());
    }
  }
}
