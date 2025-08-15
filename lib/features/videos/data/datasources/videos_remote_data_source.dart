import '../models/ad_model.dart';
import '../models/genre_with_videos_model.dart';

abstract class VideosRemoteDataSource {
  /// Obtiene todos los videos desde la API
  Future<List<AdModel>> getVideos();

  /// Obtiene videos paginados con soporte para filtrar por categoría
  Future<List<AdModel>> getVideosPaginated({
    required int page,
    int limit = 10,
    int? categoryId,
  });
  
  /// Obtiene videos aleatorios con soporte para filtrar por categoría
  Future<List<AdModel>> getRandomVideos({
    int limit = 10,
    int? categoryId,
  });

  /// Obtiene videos agrupados por género usando la vista group_ad_by_genre de Supabase
  Future<List<GenreWithVideosModel>> getVideosByGenre();

  /// Obtiene un video específico por ID
  Future<AdModel> getVideo(String id);

  /// Marca un video como visto
  Future<bool> markVideoAsViewed(String id);

  /// Marca un video como "me gusta"
  Future<bool> likeVideo(String id);

  /// Elimina el "me gusta" de un video
  Future<bool> unlikeVideo(String id);
}
