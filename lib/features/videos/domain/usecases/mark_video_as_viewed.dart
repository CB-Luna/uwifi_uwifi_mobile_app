import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/videos_repository.dart';
import 'params.dart';

/// Caso de uso para marcar un video como visto
class MarkVideoAsViewed implements UseCase<bool, VideoParams> {
  final VideosRepository repository;

  MarkVideoAsViewed(this.repository);

  @override
  Future<Either<Failure, bool>> call(VideoParams params) {
    return repository.markVideoAsViewed(params.id);
  }
}
