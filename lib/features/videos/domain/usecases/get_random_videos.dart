import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';

/// Caso de uso para obtener videos aleatorios
class GetRandomVideos implements UseCase<List<Ad>, RandomVideosParams> {
  final VideosRepository repository;

  GetRandomVideos(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(RandomVideosParams params) async {
    return await repository.getRandomVideos(
      limit: params.limit,
      categoryId: params.categoryId,
    );
  }
}

/// Parámetros para obtener videos aleatorios
class RandomVideosParams {
  final int limit;
  final int? categoryId;

  RandomVideosParams({
    this.limit = 10,
    this.categoryId,
  });
}
