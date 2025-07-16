import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/credit_card_model.dart';
import 'payment_remote_data_source.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;
  final http.Client client;

  PaymentRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.client,
  });

  @override
  Future<Either<Failure, List<CreditCardModel>>> getCreditCards(
    String customerId,
  ) async {
    try {
      AppLogger.navInfo(
        'Obteniendo tarjetas de crédito para customerId: $customerId',
      );

      // Realizar la solicitud GET a la tabla credit_card
      final response = await supabaseClient
          .from('credit_card')
          .select()
          .eq('customer_fk', customerId)
          .eq('is_active', true);

      // Convertir la respuesta a una lista de modelos
      final creditCards = (response as List)
          .map((item) => CreditCardModel.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.navInfo('Tarjetas de crédito obtenidas: ${creditCards.length}');

      return Right(creditCards);
    } catch (e) {
      AppLogger.navError('Error al obtener tarjetas de crédito: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> setDefaultCard({
    required String customerId,
    required String cardId,
  }) async {
    try {
      AppLogger.navInfo(
        'Estableciendo tarjeta $cardId como predeterminada para customerId: $customerId',
      );

      // Convertir customerId y cardId a enteros
      final customerIdInt = int.parse(customerId);
      final cardIdInt = int.parse(cardId);

      AppLogger.navInfo(
        'Enviando request con customer_fk: $customerIdInt, credit_card_id: $cardIdInt',
      );

      final response = await client.post(
        Uri.parse(ApiEndpoints.updateDefaultCreditCard),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_fk': customerIdInt,
          'credit_card_id': cardIdInt,
        }),
      );

      if (response.statusCode != 200) {
        AppLogger.navError(
          'Error al establecer tarjeta como predeterminada. Código: ${response.statusCode}, Respuesta: ${response.body}',
        );
        return const Left(ServerFailure('Failed to set default card'));
      }

      AppLogger.navInfo(
        'Tarjeta establecida como predeterminada correctamente',
      );
      return const Right(true);
    } catch (e) {
      AppLogger.navError('Error al establecer tarjeta como predeterminada: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCreditCard({
    required String customerId,
    required String cardId,
  }) async {
    try {
      AppLogger.navInfo(
        'Eliminando tarjeta $cardId para customerId: $customerId',
      );

      // Convertir cardId a entero
      final cardIdInt = int.parse(cardId);

      AppLogger.navInfo('Enviando request con credit_card_id: $cardIdInt');

      final response = await client.post(
        Uri.parse(ApiEndpoints.deleteCreditCard),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'credit_card_id': cardIdInt}),
      );

      if (response.statusCode != 200) {
        AppLogger.navError(
          'Error al eliminar tarjeta. Código: ${response.statusCode}, Respuesta: ${response.body}',
        );
        return const Left(ServerFailure('Error al eliminar tarjeta'));
      }

      AppLogger.navInfo('Tarjeta eliminada correctamente');
      return const Right(true);
    } catch (e) {
      AppLogger.navError('Error al eliminar tarjeta: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
