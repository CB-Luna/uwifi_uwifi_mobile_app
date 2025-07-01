import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/genre_with_videos.dart';
import '../repositories/videos_repository.dart';

/// Caso de uso para obtener videos agrupados por género/categoría
class GetVideosByGenre implements UseCase<List<GenreWithVideos>, NoParams> {
  final VideosRepository repository;

  GetVideosByGenre(this.repository);

  @override
  Future<Either<Failure, List<GenreWithVideos>>> call(NoParams params) {
    return repository.getVideosByGenre();
  }
}
