import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';
import 'params.dart';

/// Caso de uso para obtener videos paginados de la tabla ad
/// Permite filtrar por categoría si se proporciona categoryId
class GetVideosPaginated implements UseCase<List<Ad>, VideosPaginatedParams> {
  final VideosRepository repository;

  GetVideosPaginated(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(VideosPaginatedParams params) {
    return repository.getVideosPaginated(
      page: params.page,
      limit: params.limit,
      categoryId: params.categoryId,
    );
  }
}
