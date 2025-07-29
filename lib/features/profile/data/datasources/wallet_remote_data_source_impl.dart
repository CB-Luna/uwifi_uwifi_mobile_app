import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/affiliated_user_model.dart';
import '../models/customer_points_model.dart';
import 'wallet_remote_data_source.dart';

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final SupabaseClient supabaseClient;

  WalletRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<AffiliatedUserModel>>> getAffiliatedUsers(
    String customerId,
  ) async {
    try {
      // Preparar el cuerpo de la solicitud
      final requestBody = {'customerid': customerId};

      AppLogger.navInfo(
        'Obteniendo usuarios afiliados para customerId: $customerId con params: $requestBody',
      );

      // Realizar la solicitud a la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'get_afiliate_customers',
        params: requestBody,
      );

      // Log de la respuesta completa para diagnóstico
      AppLogger.navInfo('Respuesta RPC raw: $response');

      if (response == null) {
        AppLogger.navError(
          'Error al obtener usuarios afiliados: respuesta nula',
        );
        return const Left(ServerFailure('Error al obtener usuarios afiliados'));
      }

      // Verificar si la respuesta es una lista
      if (response is! List) {
        AppLogger.navError(
          'Error al obtener usuarios afiliados: formato incorrecto. Tipo: ${response.runtimeType}',
        );
        return const Left(ServerFailure('Formato de respuesta incorrecto'));
      }

      // Si la lista está vacía, retornar una lista vacía válida en lugar de error
      if (response.isEmpty) {
        AppLogger.navInfo('No se encontraron usuarios afiliados para este cliente');
        return const Right([]);
      }

      try {
        // Convertir la respuesta a una lista de modelos
        final affiliatedUsers = (response)
            .map(
              (item) => AffiliatedUserModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        AppLogger.navInfo(
          'Usuarios afiliados obtenidos y procesados: ${affiliatedUsers.length}',
        );

        return Right(affiliatedUsers);
      } catch (parseError) {
        AppLogger.navError('Error al parsear usuarios afiliados: $parseError');
        AppLogger.navError('Contenido de la respuesta: $response');
        return Left(ServerFailure('Error al procesar datos de usuarios afiliados: $parseError'));
      }
    } catch (e) {
      AppLogger.navError('Error al obtener usuarios afiliados: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerPointsModel>> getCustomerPoints(
    String customerId,
    {String? customerAfiliateId}
  ) async {
    try {
      // Preparar el cuerpo de la solicitud
      final requestBody = {
        'var_customer_id': int.parse(customerId),
        'var_customer_afiliate_id': int.parse(customerAfiliateId ?? customerId)
      };

      AppLogger.navInfo(
        'Obteniendo puntos del cliente para customerId: $customerId',
      );

      // Realizar la solicitud a la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'customer_current_point',
        params: requestBody,
      );

      if (response == null) {
        AppLogger.navError(
          'Error al obtener puntos del cliente: respuesta nula',
        );
        return const Left(ServerFailure('Error al obtener puntos del cliente'));
      }

      // Verificar si la respuesta es una lista
      if (response is! List) {
        AppLogger.navError(
          'Error al obtener puntos del cliente: formato de respuesta inválido',
        );
        return const Left(
          ServerFailure('Formato de respuesta inválido para puntos del cliente'),
        );
      }

      // Verificar si la lista está vacía
      if (response.isEmpty) {
        AppLogger.navError(
          'Error al obtener puntos del cliente: no se encontraron datos',
        );
        return const Left(
          ServerFailure('No se encontraron datos de puntos para este cliente'),
        );
      }

      // Convertir la respuesta a un modelo
      final customerPointsData = response[0] as Map<String, dynamic>;
      final customerPoints = CustomerPointsModel.fromJson(customerPointsData);

      AppLogger.navInfo(
        'Puntos del cliente obtenidos correctamente: ${customerPoints.totalPointsEarned}',
      );

      return Right(customerPoints);
    } catch (e) {
      AppLogger.navError('Error al obtener puntos del cliente: $e');
      return Left(ServerFailure('Error al obtener puntos del cliente: $e'));
    }
  }
}
