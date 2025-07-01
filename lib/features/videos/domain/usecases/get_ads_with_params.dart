import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';

class GetAdsWithParams implements UseCase<List<Ad>, GetAdsParams> {
  final VideosRepository repository;

  GetAdsWithParams(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(GetAdsParams params) async {
    return await repository.getVideosPaginated(
      page: params.page,
      limit: params.limit,
      categoryId: params.categoryId,
    );
  }
}

class GetAdsParams extends Equatable {
  final int page;
  final int limit;
  final int? categoryId;

  const GetAdsParams({this.page = 1, this.limit = 20, this.categoryId});

  @override
  List<Object?> get props => [page, limit, categoryId];
}
