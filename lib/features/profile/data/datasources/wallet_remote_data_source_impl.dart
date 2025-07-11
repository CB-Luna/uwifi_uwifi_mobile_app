import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/affiliated_user_model.dart';
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
        'Obteniendo usuarios afiliados para customerId: $customerId',
      );

      // Realizar la solicitud a la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'get_afiliate_customers',
        params: requestBody,
      );

      if (response == null) {
        AppLogger.navError(
          'Error al obtener usuarios afiliados: respuesta nula',
        );
        return const Left(ServerFailure('Error al obtener usuarios afiliados'));
      }

      // Verificar si la respuesta es una lista
      if (response is! List) {
        AppLogger.navError(
          'Error al obtener usuarios afiliados: formato incorrecto',
        );
        return const Left(ServerFailure('Formato de respuesta incorrecto'));
      }

      // Convertir la respuesta a una lista de modelos
      final affiliatedUsers = (response)
          .map(
            (item) =>
                AffiliatedUserModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      AppLogger.navInfo(
        'Usuarios afiliados obtenidos: ${affiliatedUsers.length}',
      );

      return Right(affiliatedUsers);
    } catch (e) {
      AppLogger.navError('Error al obtener usuarios afiliados: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
