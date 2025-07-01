import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/videos_repository.dart';
import 'params.dart';

/// Caso de uso para dar like a un video
class LikeVideo implements UseCase<bool, VideoParams> {
  final VideosRepository repository;

  LikeVideo(this.repository);

  @override
  Future<Either<Failure, bool>> call(VideoParams params) {
    return repository.likeVideo(params.id);
  }
}
