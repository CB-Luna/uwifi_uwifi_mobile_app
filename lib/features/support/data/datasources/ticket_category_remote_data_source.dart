import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/ticket_category_model.dart';

abstract class TicketCategoryRemoteDataSource {
  /// Obtiene las categorías de tickets de soporte desde la API
  ///
  /// Lanza [ServerException] si ocurre un error
  Future<List<TicketCategoryModel>> getTicketCategories();
}

class TicketCategoryRemoteDataSourceImpl
    implements TicketCategoryRemoteDataSource {
  final SupabaseClient supabaseClient;

  TicketCategoryRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<TicketCategoryModel>> getTicketCategories() async {
    try {
      AppLogger.navInfo('Getting support ticket categories');

      // Llamar a la función RPC en Supabase
      final response = await supabaseClient
          .from('support_ticket_category')
          .select();

      AppLogger.navInfo('Response received: $response');

      // Procesar la respuesta
      final List<dynamic> responseData = response;

      // Convertir cada elemento de la lista a un modelo
      return responseData
          .map((item) => TicketCategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      AppLogger.navError('Error in getTicketCategories: $e');
      throw ServerException(e.toString());
    }
  }
}
