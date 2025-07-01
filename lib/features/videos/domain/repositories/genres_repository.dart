import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/genre.dart';
import '../entities/genre_with_videos.dart';

/// Interfaz que define las operaciones disponibles para el repositorio de géneros/categorías
abstract class GenresRepository {
  /// Obtiene todas las categorías
  Future<Either<Failure, List<Genre>>> getGenres();

  /// Obtiene una categoría específica por ID
  Future<Either<Failure, Genre>> getGenre(int id);

  /// Obtiene solo las categorías visibles
  Future<Either<Failure, List<Genre>>> getVisibleGenres();
  
  /// Obtiene las categorías con sus videos desde la vista group_ad_by_genre
  Future<Either<Failure, List<GenreWithVideos>>> getGenresWithVideos();
}
