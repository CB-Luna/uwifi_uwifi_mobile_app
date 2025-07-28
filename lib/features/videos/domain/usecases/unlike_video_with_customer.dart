import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';
import 'package:uwifiapp/features/videos/domain/repositories/video_likes_repository.dart';
import 'package:uwifiapp/features/videos/domain/usecases/like_video_with_customer.dart';

/// Caso de uso para quitar like a un video con el ID del cliente
class UnlikeVideoWithCustomer implements UseCase<LikeResponse, LikeVideoParams> {
  final VideoLikesRepository repository;

  UnlikeVideoWithCustomer(this.repository);

  @override
  Future<Either<Failure, LikeResponse>> call(LikeVideoParams params) {
    return repository.unlikeVideo(params.customerId, params.videoId);
  }
}
