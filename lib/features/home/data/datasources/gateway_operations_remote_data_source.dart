import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';

abstract class GatewayOperationsRemoteDataSource {
  /// Reinicia el gateway con el número de serie proporcionado
  /// Lanza un [ServerException] si hay un error en el servidor
  Future<bool> rebootGateway(String serialNumber);
}

class GatewayOperationsRemoteDataSourceImpl implements GatewayOperationsRemoteDataSource {
  final http.Client client;

  GatewayOperationsRemoteDataSourceImpl({required this.client});

  @override
  Future<bool> rebootGateway(String serialNumber) async {
    final url = Uri.parse('${ApiEndpoints.gatewayReboot}/$serialNumber/');

    try {
      final response = await client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': ApiEndpoints.zequenceApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'operation': 'reboot'
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return true;
      } else {
        throw ServerException('Error reiniciando el gateway: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerException('Error de conexión: $e');
    }
  }
}
