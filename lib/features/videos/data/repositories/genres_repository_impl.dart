import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/genre_with_videos.dart';
import '../../domain/repositories/genres_repository.dart';
import '../datasources/genres_remote_data_source.dart';
import '../datasources/videos_remote_data_source.dart';

class GenresRepositoryImpl implements GenresRepository {
  final GenresRemoteDataSource remoteDataSource;
  final VideosRemoteDataSource videosRemoteDataSource;
  final NetworkInfo networkInfo;

  GenresRepositoryImpl({
    required this.remoteDataSource,
    required this.videosRemoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    if (await networkInfo.isConnected) {
      try {
        final genres = await remoteDataSource.getGenres();
        return Right(genres);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Genre>>> getVisibleGenres() async {
    if (await networkInfo.isConnected) {
      try {
        final genres = await remoteDataSource.getVisibleGenres();
        return Right(genres);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Genre>> getGenre(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final genre = await remoteDataSource.getGenre(id);
        return Right(genre);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<GenreWithVideos>>> getGenresWithVideos() async {
    if (await networkInfo.isConnected) {
      try {
        final genresWithVideos = await videosRemoteDataSource
            .getVideosByGenre();
        // Los modelos ya extienden de GenreWithVideos, no hay necesidad de conversión
        return Right(genresWithVideos.cast<GenreWithVideos>());
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
