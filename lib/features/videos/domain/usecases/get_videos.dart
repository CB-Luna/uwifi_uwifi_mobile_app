import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';

/// Caso de uso para obtener todos los videos de la tabla ad
class GetVideos implements UseCase<List<Ad>, NoParams> {
  final VideosRepository repository;

  GetVideos(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(NoParams params) {
    return repository.getVideos();
  }
}
