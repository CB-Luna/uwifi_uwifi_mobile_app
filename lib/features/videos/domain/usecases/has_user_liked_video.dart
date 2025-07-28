import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/videos/domain/repositories/video_likes_repository.dart';
import 'package:uwifiapp/features/videos/domain/usecases/like_video_with_customer.dart';

/// Caso de uso para verificar si un usuario ha dado like a un video
class HasUserLikedVideo implements UseCase<bool, LikeVideoParams> {
  final VideoLikesRepository repository;

  HasUserLikedVideo(this.repository);

  @override
  Future<Either<Failure, bool>> call(LikeVideoParams params) {
    return repository.hasUserLikedVideo(params.customerId, params.videoId);
  }
}
