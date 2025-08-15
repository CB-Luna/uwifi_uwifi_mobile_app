import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/ad.dart';
import '../../domain/entities/genre_with_videos.dart';
import '../../domain/repositories/videos_repository.dart';
import '../datasources/videos_local_data_source.dart';
import '../datasources/videos_remote_data_source.dart';

class VideosRepositoryImpl implements VideosRepository {
  final VideosRemoteDataSource remoteDataSource;
  final VideosLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  VideosRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Ad>>> getVideos() async {
    if (await networkInfo.isConnected) {
      try {
        final videos = await remoteDataSource.getVideos();
        await localDataSource.cacheVideos(videos);
        return Right(videos);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localVideos = await localDataSource.getLastVideos();
        return Right(localVideos);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Ad>>> getVideosPaginated({
    required int page,
    int limit = 10,
    int? categoryId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final videos = await remoteDataSource.getVideosPaginated(
          page: page,
          limit: limit,
          categoryId: categoryId,
        );
        return Right(videos);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, List<Ad>>> getRandomVideos({
    int limit = 10,
    int? categoryId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final videos = await remoteDataSource.getRandomVideos(
          limit: limit,
          categoryId: categoryId,
        );
        return Right(videos);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<GenreWithVideos>>> getVideosByGenre() async {
    if (await networkInfo.isConnected) {
      try {
        final genresWithVideos = await remoteDataSource.getVideosByGenre();
        // Podríamos cachear estos datos si es necesario
        return Right(genresWithVideos);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      // Podríamos intentar obtener datos cacheados aquí si implementamos
      // el método correspondiente en el local data source
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Ad>> getVideo(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final video = await remoteDataSource.getVideo(id);
        return Right(video);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      try {
        final localVideo = await localDataSource.getVideo(id);
        return Right(localVideo);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> markVideoAsViewed(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.markVideoAsViewed(id);
        return Right(result);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> likeVideo(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.likeVideo(id);
        return Right(result);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> unlikeVideo(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unlikeVideo(id);
        return Right(result);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
