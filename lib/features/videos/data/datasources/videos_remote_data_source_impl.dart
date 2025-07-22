import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/ad_model.dart';
import '../models/genre_with_videos_model.dart';
import 'videos_remote_data_source.dart';

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  final SupabaseClient supabaseClient;

  VideosRemoteDataSourceImpl({required this.supabaseClient});

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
      final response = await supabaseClient
          .from('ad')
          .select(
            'id, title, overview, poster_path, genre_id, video, duration_video, priority, created_at, points, video_status, partner, url_ad',
          )
          .eq('video_status', true) // Solo videos activos
          .order('priority');

      final videos = (response as List)
          .map((video) => AdModel.fromJson(video))
          .toList();

      return videos;
    });
  }

  @override
  Future<List<AdModel>> getVideosPaginated({
    required int page,
    int limit = 10,
    int? categoryId,
  }) async {
    return _retryRequest(() async {
      var query = supabaseClient
          .from('ad')
          .select(
            'id, title, overview, poster_path, genre_id, video, duration_video, priority, created_at, points, video_status, partner, url_ad',
          );

      // Filtrar solo videos activos
      query = query.eq('video_status', true);

      // Si se especifica una categoría, filtrar por ella
      if (categoryId != null && categoryId > 0) {
        debugPrint('🔎 Filtrando videos por categoría ID: $categoryId');
        query = query.eq('genre_id', categoryId);
      } else {
        debugPrint('🔎 Mostrando todos los videos (sin filtro de categoría)');
      }

      // Ordenar por prioridad y aplicar paginación
      final offset = (page - 1) * limit;
      final response = await query
          .order('priority')
          .range(offset, offset + limit - 1);

      final videos = (response as List)
          .map((video) => AdModel.fromJson(video))
          .toList();

      return videos;
    });
  }

  @override
  Future<List<GenreWithVideosModel>> getVideosByGenre() async {
    return _retryRequest(() async {
      debugPrint('🔍 Obteniendo géneros con videos...');

      // 1. Primero obtener todos los géneros para tener sus IDs correctos y poster images
      final genresResponse = await _retryRequest(() async {
        return await supabaseClient
            .from('genre_ad')
            .select('id, name, poster_img, poster_img_file')
            .eq('visible', true)
            .order('name');
      });

      final genres = (genresResponse as List)
          .map(
            (genre) => {
              'id': genre['id'] as int,
              'name': genre['name'] as String,
              'poster_img':
                  genre['poster_img'] as String? ??
                  'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
              'poster_img_file': genre['poster_img_file'] as String?,
            },
          )
          .toList();

      debugPrint('📚 Obtenidos ${genres.length} géneros desde genre_ad');

      // 2. Consultar la vista group_ad_by_genre que agrupa videos por categoría
      final response = await _retryRequest(() async {
        return await supabaseClient.from('group_ad_by_genre').select();
      });

      // 3. Mapear los resultados y asignar los IDs correctos basándonos en el nombre
      return (response as List).map((genreData) {
        final String genreName = genreData['name'] ?? '';

        // Buscar el ID correcto del género por nombre y obtener poster images
        final matchingGenre = genres.firstWhere(
          (g) => g['name'] == genreName,
          orElse: () => {
            'id': 0,
            'name': genreName,
            'poster_img':
                'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
            'poster_img_file': null,
          },
        );

        // Crear un nuevo objeto JSON con el ID correcto y poster images
        final Map<String, dynamic> enrichedGenreData = {
          ...Map<String, dynamic>.from(genreData),
          'id': matchingGenre['id'],
          'poster_img': matchingGenre['poster_img'],
          'poster_img_file': matchingGenre['poster_img_file'],
        };

        debugPrint(
          '🔑 Asignando ID ${matchingGenre['id']} al género "$genreName"',
        );

        return GenreWithVideosModel.fromJson(enrichedGenreData);
      }).toList();
    });
  }

  @override
  Future<AdModel> getVideo(int id) async {
    return _retryRequest(() async {
      final response = await supabaseClient
          .from('ad')
          .select()
          .eq('id', id)
          .single();

      return AdModel.fromJson(response);
    });
  }

  @override
  Future<bool> markVideoAsViewed(int id) async {
    try {
      // Aquí podríamos tener una tabla de visualizaciones de videos
      // por ahora simplemente retornamos true como ejemplo
      return true;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> likeVideo(int id) async {
    try {
      // Implementación para dar like a un video
      // Podría involucrar una tabla de likes de usuarios
      return true;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<bool> unlikeVideo(int id) async {
    try {
      // Implementación para quitar like a un video
      // Podría involucrar eliminar un registro de la tabla de likes
      return true;
    } catch (e) {
      throw ServerException();
    }
  }
}
