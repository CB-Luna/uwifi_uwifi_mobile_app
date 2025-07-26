import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ad.dart';
import '../entities/genre_with_videos.dart';

/// Interfaz que define las operaciones disponibles para el repositorio de videos
abstract class VideosRepository {
  /// Obtiene todos los videos
  Future<Either<Failure, List<Ad>>> getVideos();

  /// Obtiene videos paginados con un límite opcional
  Future<Either<Failure, List<Ad>>> getVideosPaginated({
    required int page,
    int limit = 10,
    int? categoryId,
  });

  /// Obtiene videos agrupados por género/categoría
  Future<Either<Failure, List<GenreWithVideos>>> getVideosByGenre();

  /// Obtiene un video específico por ID
  Future<Either<Failure, Ad>> getVideo(String id);

  /// Marca un video como visto
  Future<Either<Failure, bool>> markVideoAsViewed(String id);

  /// Marca un video como "me gusta"
  Future<Either<Failure, bool>> likeVideo(String id);

  /// Elimina el "me gusta" de un video
  Future<Either<Failure, bool>> unlikeVideo(String id);
}
