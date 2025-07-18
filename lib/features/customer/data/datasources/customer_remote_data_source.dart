import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/customer_details_model.dart';

abstract class CustomerRemoteDataSource {
  /// Calls the get_customer_details endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<CustomerDetailsModel> getCustomerDetails(int customerId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CustomerDetailsModel> getCustomerDetails(int customerId) async {
    try {
      AppLogger.navInfo(
        'Obteniendo detalles del cliente para customerId: $customerId',
      );

      // Preparar el cuerpo de la solicitud
      final requestBody = {'customer_id': customerId};

      // Realizar la solicitud POST a la función RPC
      final response = await supabaseClient.rpc(
        'get_customer_details',
        params: requestBody,
      );

      AppLogger.navInfo('Respuesta recibida: $response');

      if (response == null) {
        AppLogger.navError(
          'Error al obtener detalles del cliente: respuesta nula',
        );
        throw ServerException('Error al obtener detalles del cliente');
      }

      // La respuesta ya es la lista de resultados
      if (response is List) {
        // Si la respuesta es directamente una lista
        final List<dynamic> responseData = response;
        
        if (responseData.isEmpty) {
          throw ServerException('No se encontraron detalles para el cliente');
        }
        
        // Convertir la respuesta a un modelo
        return CustomerDetailsModel.fromJson(responseData[0]);
      } else {
        // Si la respuesta es un mapa u otro tipo
        AppLogger.navInfo('Tipo de respuesta: ${response.runtimeType}');
        
        // Intentar convertir la respuesta a un modelo directamente
        try {
          if (response is Map<String, dynamic>) {
            return CustomerDetailsModel.fromJson(response);
          } else {
            throw ServerException('Formato de respuesta inesperado');
          }
        } catch (e) {
          AppLogger.navError('Error al parsear la respuesta: $e');
          throw ServerException('Error al parsear la respuesta: $e');
        }
      }
    } catch (e) {
      AppLogger.navError('Error en getCustomerDetails: $e');
      throw ServerException(e.toString());
    }
  }
}
