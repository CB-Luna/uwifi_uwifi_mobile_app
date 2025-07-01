import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/videos_repository.dart';
import 'params.dart';

/// Caso de uso para quitar like de un video
class UnlikeVideo implements UseCase<bool, VideoParams> {
  final VideosRepository repository;

  UnlikeVideo(this.repository);

  @override
  Future<Either<Failure, bool>> call(VideoParams params) {
    return repository.unlikeVideo(params.id);
  }
}
