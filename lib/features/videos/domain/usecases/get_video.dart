import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';
import 'params.dart';

/// Caso de uso para obtener un video específico por ID
class GetVideo implements UseCase<Ad, VideoParams> {
  final VideosRepository repository;

  GetVideo(this.repository);

  @override
  Future<Either<Failure, Ad>> call(VideoParams params) {
    return repository.getVideo(params.id);
  }
}
