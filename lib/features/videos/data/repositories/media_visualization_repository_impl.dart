import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/media_visualization.dart';
import '../../domain/repositories/media_visualization_repository.dart';
import '../datasources/media_visualization_remote_data_source.dart';
import '../models/media_visualization_model.dart';

/// Implementación del repositorio para manejar las visualizaciones de medios
class MediaVisualizationRepositoryImpl implements MediaVisualizationRepository {
  final MediaVisualizationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MediaVisualizationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, bool>> registerMediaVisualization(
    MediaVisualization visualization,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final model = MediaVisualizationModel.fromEntity(visualization);
        final result = await remoteDataSource.registerMediaVisualization(model);
        return Right(result);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
