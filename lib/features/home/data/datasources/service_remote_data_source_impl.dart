import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';

import '../models/active_service_model.dart';
import 'service_remote_data_source.dart';

class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final SupabaseClient supabaseClient;

  ServiceRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<ActiveServiceModel>>> getCustomerActiveServices(
    String customerId,
  ) async {
    try {
      // Preparar el cuerpo de la solicitud
      final requestBody = {'customer_id': int.parse(customerId)};

      AppLogger.navInfo(
        'Obteniendo servicios activos para customerId: $customerId',
      );

      // Realizar la solicitud a la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'get_customer_active_services',
        params: requestBody,
      );

      AppLogger.navInfo('Respuesta recibida: $response');

      if (response == null) {
        AppLogger.navError(
          'Error al obtener servicios activos: respuesta nula',
        );
        return const Left(ServerFailure('Error al obtener servicios activos'));
      }

      // Verificar si la respuesta es una lista
      if (response is! List) {
        AppLogger.navError(
          'Error al obtener servicios activos: formato de respuesta incorrecto',
        );
        return const Left(
          ServerFailure('Formato de respuesta incorrecto'),
        );
      }

      // Convertir la respuesta a una lista de modelos
      final servicesList = (response)
          .map(
            (item) => ActiveServiceModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      AppLogger.navInfo(
        'Servicios activos obtenidos: ${servicesList.length}',
      );

      return Right(servicesList);
    } on PostgrestException catch (e) {
      AppLogger.navError('Error de Postgrest: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      AppLogger.navError('Error al obtener servicios activos: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
