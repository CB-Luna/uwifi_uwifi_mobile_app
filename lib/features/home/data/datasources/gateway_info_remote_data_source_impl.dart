import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/gateway_info_model.dart';
import 'gateway_info_remote_data_source.dart';

class GatewayInfoRemoteDataSourceImpl implements GatewayInfoRemoteDataSource {
  final http.Client client;

  GatewayInfoRemoteDataSourceImpl({required this.client});

  @override
  Future<GatewayInfoModel> getGatewayInfo(String serialNumber) async {
    try {
      AppLogger.navInfo(
        'Solicitando información del gateway con serial: $serialNumber',
      );

      final response = await client.post(
        Uri.parse(ApiEndpoints.gatewayInfo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'parent__serial_number': serialNumber}),
      );

      if (response.statusCode != 200) {
        AppLogger.navError('Error al obtener información del gateway: ${response.body}');
        throw ServerException('Error al obtener información del gateway: ${response.statusCode}');
      }

      AppLogger.navInfo('Información del gateway obtenida con éxito');
      return GatewayInfoModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      AppLogger.navError('Error al obtener información del gateway: $e');
      throw ServerException(e.toString());
    }
  }
}
