import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/ad.dart';
import '../models/ad_model.dart';

/// Servicio para buscar videos usando la función RPC de Supabase
class VideoSearchService {
  late final SupabaseClient _mediaLibraryClient;

  VideoSearchService({required SupabaseClient supabaseClient}) {
    _mediaLibraryClient = GetIt.instance.get<SupabaseClient>(
      instanceName: 'mediaLibraryClient',
    );
  }

  /// Busca videos usando la función RPC search_videos
  Future<List<Ad>> searchVideos(String searchTerm) async {
    try {
      AppLogger.videoInfo('🔍 Buscando videos con RPC: "$searchTerm"');

      final response = await _mediaLibraryClient.rpc(
        'search_videos',
        params: {'search_term': searchTerm},
      );

      if (response.isEmpty) {
        throw Exception(
          'No se encontraron videos para el término de búsqueda: $searchTerm',
        );
      }

      final List<Ad> videos = (response as List<dynamic>)
          .map(
            (videoData) => AdModel.fromJson(videoData as Map<String, dynamic>),
          )
          .toList();

      AppLogger.videoInfo(
        '✅ Búsqueda RPC completada: ${videos.length} resultados',
      );
      return videos;
    } catch (e) {
      AppLogger.videoError('❌ Error en búsqueda RPC: $e');
      rethrow;
    }
  }
}
