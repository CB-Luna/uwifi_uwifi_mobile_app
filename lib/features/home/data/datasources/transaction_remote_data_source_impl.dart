import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/transaction_model.dart';
import 'transaction_remote_data_source.dart';

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactionHistory(
    String customerId,
  ) async {
    try {
      AppLogger.navInfo(
        'Obteniendo historial de transacciones para customerId: $customerId',
      );

      // Realizar la solicitud GET a la tabla customer_transaction
      final response = await supabaseClient
          .from('customer_transaction')
          .select()
          .eq('customer_id', int.parse(customerId))
          .order('created_at', ascending: false);

      // Convertir la respuesta a una lista de modelos
      final transactions = (response as List)
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.navInfo(
        'Transacciones obtenidas: ${transactions.length}',
      );

      return Right(transactions);
    } catch (e) {
      AppLogger.navError('Error al obtener transacciones: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
