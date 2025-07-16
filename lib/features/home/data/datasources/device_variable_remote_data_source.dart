import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uwifiapp/core/constants/api_endpoints.dart';
import 'package:uwifiapp/core/errors/exceptions.dart';
import 'package:uwifiapp/features/home/data/models/device_variable_model.dart';

abstract class DeviceVariableRemoteDataSource {
  /// Updates a device variable for the specified serial number
  /// Throws a [ServerException] for all error codes
  Future<bool> updateDeviceVariable(
    String serialNumber,
    DeviceVariableModel variable,
  );
}

class DeviceVariableRemoteDataSourceImpl
    implements DeviceVariableRemoteDataSource {
  final http.Client client;

  DeviceVariableRemoteDataSourceImpl({required this.client});

  @override
  Future<bool> updateDeviceVariable(
    String serialNumber,
    DeviceVariableModel variable,
  ) async {
    final url = Uri.parse('${ApiEndpoints.deviceVariables}/$serialNumber/');

    try {
      final response = await client.put(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': ApiEndpoints.zequenceApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode(variable.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw ServerException(
          'Failed to update device variable: ${response.body}',
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Error updating device variable: ${e.toString()}');
    }
  }
}
