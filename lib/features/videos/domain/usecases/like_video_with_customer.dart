import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/usecases/usecase.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';
import 'package:uwifiapp/features/videos/domain/repositories/video_likes_repository.dart';

/// Caso de uso para dar like a un video con el ID del cliente
class LikeVideoWithCustomer implements UseCase<LikeResponse, LikeVideoParams> {
  final VideoLikesRepository repository;

  LikeVideoWithCustomer(this.repository);

  @override
  Future<Either<Failure, LikeResponse>> call(LikeVideoParams params) {
    return repository.likeVideo(params.customerId, params.videoId);
  }
}

/// Parámetros para el caso de uso LikeVideoWithCustomer
class LikeVideoParams extends Equatable {
  final int customerId;
  final String videoId;

  const LikeVideoParams({
    required this.customerId,
    required this.videoId,
  });

  @override
  List<Object?> get props => [customerId, videoId];
}
