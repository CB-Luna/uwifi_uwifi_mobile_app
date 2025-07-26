import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/ad_model.dart';
import '../models/genre_with_videos_model.dart';
import 'videos_remote_data_source.dart';

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final SupabaseClient supabaseClient;
  late final SupabaseClient _mediaLibraryClient;

  VideosRemoteDataSourceImpl({required this.supabaseClient}) {
    // Obtener el cliente específico para el esquema media_library
    _mediaLibraryClient = GetIt.instance.get<SupabaseClient>(instanceName: 'mediaLibraryClient');
  }

  /// Método helper para reintentar requests con backoff exponencial
  Future<T> _retryRequest<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        return await request();
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          debugPrint('❌ Máximo de reintentos alcanzado para request: $e');
          rethrow;
        }

        final delayMs =
            (attempt * 1000) + (attempt * 500); // Backoff exponencial
        debugPrint(
          '🔄 Reintentando request en ${delayMs}ms (intento $attempt/$maxRetries)',
        );
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    throw ServerException();
  }

  @override
  Future<List<AdModel>> getVideos() async {
    return _retryRequest(() async {
      final response = await _mediaLibraryClient
          .from('vw_media_files_with_posters')
          .select(
            'media_file_id, media_title, file_description, poster_url, category_id, category_name, category_image_url, media_url, media_created_at, media_type, media_mime_type, poster_title, poster_created_at',
          )
          .eq('media_type', 'video') // Solo archivos de tipo video
          .order('media_created_at', ascending: false);

      return (response as List)
          .map((json) => AdModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<List<AdModel>> getVideosPaginated({
    required int page,
    int limit = 10,
    int? categoryId,
  }) async {
    return _retryRequest(() async {
      var query = _mediaLibraryClient
          .from('vw_media_files_with_posters')
          .select(
            'media_file_id, media_title, file_description, poster_url, category_id, category_name, category_image_url, media_url, media_created_at, media_type, media_mime_type, poster_title, poster_created_at',
          );

      // Filtrar solo archivos de tipo video
      query = query.eq('media_type', 'video');

      // Si se especifica una categoría, filtrar por ella
      if (categoryId != null && categoryId > 0) {
        debugPrint('🔎 Filtrando videos por categoría ID: $categoryId');
        query = query.eq('category_id', categoryId);
      } else {
        debugPrint('🔎 Mostrando todos los videos (sin filtro de categoría)');
      }

      // Ordenar por fecha de creación y aplicar paginación
      final offset = (page - 1) * limit;
      final finalQuery = query
          .order('media_created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await finalQuery;

      return (response as List)
          .map((json) => AdModel.fromJson(json))
          .toList();
    });
  }

  @override
  Future<List<GenreWithVideosModel>> getVideosByGenre() async {
    return _retryRequest(() async {
      debugPrint('🔍 Obteniendo géneros con videos...');

      // 1. Primero obtener todos los géneros desde la nueva tabla media_categories
      final genresResponse = await _retryRequest(() async {
        return await _mediaLibraryClient
            .from('media_categories')
            .select('media_categories_id, category_name, category_description')
            .order('category_name');
      });

      final genres = (genresResponse as List).map((json) {
        return {
          'id': json['media_categories_id'] as String,
          'name': json['category_name'] as String,
          'description': json['category_description'] as String?,
          // Usamos una imagen por defecto para mantener compatibilidad con la UI
          'poster_img': 'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
        };
      }).toList();

      debugPrint('📚 Obtenidos ${genres.length} géneros desde media_categories');

      // 2. Ahora agrupamos videos por categoría usando la vista de media_files
      // Primero obtenemos todos los videos
      final videosResponse = await _retryRequest(() async {
        return await _mediaLibraryClient
            .from('vw_media_files_with_posters')
            .select()
            .eq('media_type', 'video');
      });
      
      final videos = videosResponse as List;
      debugPrint('🎥 Obtenidos ${videos.length} videos desde vw_media_files_with_posters');
      
      // Agrupamos los videos por categoría
      final Map<String, List<Map<String, dynamic>>> videosByCategory = {};
      
      for (var video in videos) {
        final categoryName = video['category_name'] ?? 'Sin categoría';
        if (!videosByCategory.containsKey(categoryName)) {
          videosByCategory[categoryName] = [];
        }
        videosByCategory[categoryName]!.add(video);
      }
      
      // 3. Crear los objetos GenreWithVideosModel
      return videosByCategory.entries.map((entry) {
        final String genreName = entry.key;
        final List<Map<String, dynamic>> categoryVideos = entry.value;
        
        // Buscar el ID correcto del género por nombre
        final matchingGenre = genres.firstWhere(
          (g) => g['name'] == genreName,
          orElse: () => {
            'id': '0', // Ahora los IDs son String
            'name': genreName,
            'description': null,
            'poster_img': 'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
          },
        );
        
        // Crear un nuevo objeto JSON con el ID correcto y los videos
        final Map<String, dynamic> enrichedGenreData = {
          'id': matchingGenre['id'],
          'name': genreName,
          'description': matchingGenre['description'],
          'poster_img': matchingGenre['poster_img'],
          'videos': categoryVideos,
        };

        debugPrint(
          '🔑 Procesando categoría "$genreName" (ID: ${matchingGenre['id']}) con ${categoryVideos.length} videos',
        );

        return GenreWithVideosModel.fromJson(enrichedGenreData);
      }).toList();
    });
  }

  @override
  Future<AdModel> getVideo(String id) async {
    return _retryRequest(() async {
      final response = await _mediaLibraryClient
          .from('vw_media_files_with_posters')
          .select()
          .eq('media_file_id', id)
          .single();

      return AdModel.fromJson(response);
    });
  }

  @override
  Future<bool> markVideoAsViewed(String id) async {
    try {
      // Aquí podríamos tener una tabla de visualizaciones de videos
      // por ahora simplemente retornamos true como ejemplo
      return true;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> likeVideo(String id) async {
    try {
      // Implementación para dar like a un video
      // Podría involucrar una tabla de likes de usuarios
      return true;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> unlikeVideo(String id) async {
    try {
      // Implementación para quitar like a un video
      // Podría involucrar eliminar un registro de la tabla de likes
      return true;
    } catch (e) {
      throw ServerException();
    }
  }
}
