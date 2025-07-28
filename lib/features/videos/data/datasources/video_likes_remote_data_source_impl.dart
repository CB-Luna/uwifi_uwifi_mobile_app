import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uwifiapp/core/errors/exceptions.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/features/videos/data/datasources/video_likes_remote_data_source.dart';
import 'package:uwifiapp/features/videos/data/models/like_response_model.dart';

class VideoLikesRemoteDataSourceImpl implements VideoLikesRemoteDataSource {
  final SupabaseClient supabaseClient;
  late final SupabaseClient _transactionsClient;

  VideoLikesRemoteDataSourceImpl({required this.supabaseClient}) {
    // Obtener el cliente específico para el esquema transactions
    _transactionsClient = GetIt.instance.get<SupabaseClient>(
      instanceName: 'transactionsClient',
    );
  }

  /// Método helper para reintentar requests con backoff exponencial
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    String functionName = 'desconocida',
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e, stackTrace) {
        attempt++;
        if (attempt >= maxRetries) {
          debugPrint(
            '❌ Función: $functionName - Máximo de reintentos alcanzado: $e',
          );
          debugPrint('❌ StackTrace: $stackTrace');
          rethrow;
        }
        final delayMs =
            (attempt * 1000) + (attempt * 500); // Backoff exponencial
        debugPrint(
          '🔄 Función: $functionName - Reintentando request en ${delayMs}ms (intento $attempt/$maxRetries)',
        );
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    throw ServerException();
  }

  @override
  Future<LikeResponseModel> likeVideo(int customerId, String videoId) async {
    return _retryRequest(() async {
      try {
        AppLogger.navInfo(
          'Registrando like para video: $videoId del cliente: $customerId',
        );

        // Insertar en la tabla customer_liked
        final response = await _transactionsClient
            .from('customer_liked')
            .insert({
              'customer_fk': customerId,
              'media_file_fk': videoId,
            })
            .select()
            .single();

        AppLogger.navInfo('Like registrado con éxito: $response');

        return LikeResponseModel(
          success: true,
          message: 'Like registrado con éxito',
          likeId: response['customer_liked_id'],
        );
      } catch (e) {
        AppLogger.navError('Error al registrar like: $e');
        return const LikeResponseModel(
          success: false,
          message: 'Error al registrar like',
        );
      }
    }, functionName: 'likeVideo');
  }

  @override
  Future<LikeResponseModel> unlikeVideo(int customerId, String videoId) async {
    return _retryRequest(() async {
      try {
        AppLogger.navInfo(
          'Eliminando like para video: $videoId del cliente: $customerId',
        );

        // Eliminar de la tabla customer_liked
        await _transactionsClient
            .from('customer_liked')
            .delete()
            .eq('customer_fk', customerId)
            .eq('media_file_fk', videoId);

        AppLogger.navInfo('Like eliminado con éxito');

        return const LikeResponseModel(
          success: true,
          message: 'Like eliminado con éxito',
        );
      } catch (e) {
        AppLogger.navError('Error al eliminar like: $e');
        return const LikeResponseModel(
          success: false,
          message: 'Error al eliminar like',
        );
      }
    }, functionName: 'unlikeVideo');
  }

  @override
  Future<bool> hasUserLikedVideo(int customerId, String videoId) async {
    return _retryRequest(() async {
      try {
        AppLogger.navInfo(
          'Verificando like para video: $videoId del cliente: $customerId',
        );

        // Consultar si existe un registro en la tabla customer_liked
        final response = await _transactionsClient
            .from('customer_liked')
            .select()
            .eq('customer_fk', customerId)
            .eq('media_file_fk', videoId);

        // Si hay resultados, el usuario ha dado like al video
        final hasLiked = response.isNotEmpty;
        
        AppLogger.navInfo('Usuario ha dado like: $hasLiked');
        
        return hasLiked;
      } catch (e) {
        AppLogger.navError('Error al verificar like: $e');
        // En caso de error, asumimos que no hay like
        return false;
      }
    }, functionName: 'hasUserLikedVideo');
  }
}
