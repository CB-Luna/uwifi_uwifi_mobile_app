import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/customer_bundle_model.dart';
import 'customer_bundle_remote_data_source.dart';

class CustomerBundleRemoteDataSourceImpl implements CustomerBundleRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerBundleRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CustomerBundleModel>> getCustomerBundle(int customerId) async {
    try {
      AppLogger.navInfo(
        'Solicitando bundle del cliente: $customerId',
      );

      final response = await supabaseClient.rpc(
        'customer_bundle',
        params: {'customer_id': customerId},
      );

      // Verificar si la respuesta es válida
      if (response == null) {
        AppLogger.navError('Error: respuesta nula al obtener bundle del cliente');
        throw ServerException('Error: respuesta nula al obtener bundle del cliente');
      }

      AppLogger.navInfo('Respuesta de bundle del cliente: ${jsonEncode(response)}');

      // Convertir la respuesta a una lista de modelos
      if (response is List) {
        return response
            .map((item) => CustomerBundleModel.fromJson(item))
            .toList();
      } else {
        AppLogger.navError('Error: formato de respuesta inesperado');
        throw ServerException('Error: formato de respuesta inesperado');
      }
    } catch (e) {
      AppLogger.navError('Error al obtener bundle del cliente: $e');
      throw ServerException(e.toString());
    }
  }
}
