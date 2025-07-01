import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/genre_with_videos.dart';
import '../repositories/genres_repository.dart';

/// Caso de uso para obtener todas las categorías con sus videos desde la vista group_ad_by_genre
class GetGenres implements UseCase<List<GenreWithVideos>, NoParams> {
  final GenresRepository repository;

  GetGenres(this.repository);

  @override
  Future<Either<Failure, List<GenreWithVideos>>> call(NoParams params) {
    return repository.getGenresWithVideos(); // Categorías con sus videos
  }
}
