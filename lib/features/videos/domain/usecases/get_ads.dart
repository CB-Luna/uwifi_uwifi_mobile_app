import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ad.dart';
import '../repositories/videos_repository.dart';

class GetAds implements UseCase<List<Ad>, NoParams> {
  final VideosRepository repository;

  GetAds(this.repository);

  @override
  Future<Either<Failure, List<Ad>>> call(NoParams params) async {
    return await repository.getVideos();
  }
}
