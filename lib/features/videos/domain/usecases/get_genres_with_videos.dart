import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/genre_with_videos.dart';
import '../repositories/genres_repository.dart';

/// Use case para obtener géneros con sus videos asociados
class GetGenresWithVideos implements UseCase<List<GenreWithVideos>, NoParams> {
  final GenresRepository repository;

  GetGenresWithVideos(this.repository);

  @override
  Future<Either<Failure, List<GenreWithVideos>>> call(NoParams params) async {
    return await repository.getGenresWithVideos();
  }
}
