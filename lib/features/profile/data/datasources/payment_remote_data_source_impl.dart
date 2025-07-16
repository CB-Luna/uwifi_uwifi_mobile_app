import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/credit_card_model.dart';
import 'payment_remote_data_source.dart';

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

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

      AppLogger.navInfo(
        'Tarjetas de crédito obtenidas: ${creditCards.length}',
      );

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
      
      // Primero, establecer todas las tarjetas del cliente como no predeterminadas
      await supabaseClient
          .from('credit_card')
          .update({'is_default': false})
          .eq('customer_fk', customerId);
      
      // Luego, establecer la tarjeta seleccionada como predeterminada
      await supabaseClient
          .from('credit_card')
          .update({'is_default': true})
          .eq('id', cardId)
          .eq('customer_fk', customerId);
      
      AppLogger.navInfo('Tarjeta establecida como predeterminada correctamente');
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
      
      // En lugar de eliminar físicamente la tarjeta, la marcamos como inactiva
      await supabaseClient
          .from('credit_card')
          .update({'is_active': false})
          .eq('id', cardId)
          .eq('customer_fk', customerId);
      
      AppLogger.navInfo('Tarjeta eliminada correctamente');
      return const Right(true);
    } catch (e) {
      AppLogger.navError('Error al eliminar tarjeta: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
