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
        'Requesting gateway information with serial: $serialNumber',
      );

      final response = await client.post(
        Uri.parse(ApiEndpoints.gatewayInfo),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'parent__serial_number': serialNumber}),
      );

      if (response.statusCode != 200) {
        AppLogger.navError('Error getting gateway information: ${response.body}');
        throw ServerException('Error getting gateway information: ${response.statusCode}');
      }

      AppLogger.navInfo('Gateway information obtained successfully');
      return GatewayInfoModel.fromJson(
        jsonDecode(response.body),
        serialNumber: serialNumber,
      );
    } catch (e) {
      AppLogger.navError('Error getting gateway information: $e');
      throw ServerException(e.toString());
    }
  }
}
