import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/data_usage_model.dart';

abstract class GatewayRemoteDataSource {
  /// Calls the uwifi_gateway_zequence_info_usage endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<DataUsageModel> getDataUsage(String customerId);
}

class GatewayRemoteDataSourceImpl implements GatewayRemoteDataSource {
  final http.Client client;

  GatewayRemoteDataSourceImpl({required this.client});

  @override
  Future<DataUsageModel> getDataUsage(String customerId) async {
    try {
      AppLogger.navInfo(
        'Solicitando información de uso de datos para el cliente: $customerId',
      );

      final response = await client.post(
        Uri.parse(ApiEndpoints.gatewayUsageInfo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'customer_id': customerId}),
      );

      if (response.statusCode != 200) {
        AppLogger.navError('Error al obtener datos de uso: ${response.body}');
        throw ServerException('Error al obtener datos de uso: ${response.statusCode}');
      }

      AppLogger.navInfo('Datos de uso obtenidos con éxito');
      return DataUsageModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      AppLogger.navError('Error al obtener datos de uso: $e');
      throw ServerException(e.toString());
    }
  }
}
