import '../models/genre_model.dart';

abstract class GenresRemoteDataSource {
  /// Obtiene todas las categorías desde la tabla genre_ads
  Future<List<GenreModel>> getGenres();

  /// Obtiene una categoría específica por ID
  Future<GenreModel> getGenre(int id);

  /// Obtiene solo las categorías visibles
  Future<List<GenreModel>> getVisibleGenres();
}
