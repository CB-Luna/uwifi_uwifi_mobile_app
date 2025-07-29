import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/exceptions.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/core/network/network_info.dart';
import 'package:uwifiapp/features/videos/data/datasources/video_likes_remote_data_source.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';
import 'package:uwifiapp/features/videos/domain/repositories/video_likes_repository.dart';

class VideoLikesRepositoryImpl implements VideoLikesRepository {
  final VideoLikesRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VideoLikesRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LikeResponse>> likeVideo(
    int customerId,
    String videoId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.likeVideo(customerId, videoId);
        return Right(response.toEntity());
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, LikeResponse>> unlikeVideo(
    int customerId,
    String videoId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.unlikeVideo(
          customerId,
          videoId,
        );
        return Right(response.toEntity());
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserLikedVideo(
    int customerId,
    String videoId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final hasLiked = await remoteDataSource.hasUserLikedVideo(
          customerId,
          videoId,
        );
        return Right(hasLiked);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
