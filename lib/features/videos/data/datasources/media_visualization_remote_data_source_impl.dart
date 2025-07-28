import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/media_visualization_model.dart';
import 'media_visualization_remote_data_source.dart';

/// Implementación de la fuente de datos remota para manejar las visualizaciones de medios
class MediaVisualizationRemoteDataSourceImpl implements MediaVisualizationRemoteDataSource {
  final SupabaseClient transactionsClient;

  MediaVisualizationRemoteDataSourceImpl({required this.transactionsClient});

  @override
  Future<bool> registerMediaVisualization(MediaVisualizationModel visualization) async {
    try {
      // Insertar en la tabla customer_media_visualization (ya estamos en el esquema transactions)
      await transactionsClient
          .from('customer_media_visualization')
          .insert(visualization.toJson());

      AppLogger.videoInfo(
        '✅ Media visualization registered successfully: ${visualization.mediaFileId} - Points: ${visualization.pointsEarned}',
      );
      
      return true;
    } catch (e) {
      AppLogger.videoError('❌ Error registering media visualization: $e');
      throw ServerException('Error registering media visualization: $e');
    }
  }
}
