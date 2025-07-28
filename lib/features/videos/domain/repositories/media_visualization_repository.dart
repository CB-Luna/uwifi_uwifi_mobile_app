import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/media_visualization.dart';

/// Repositorio para manejar las visualizaciones de medios
abstract class MediaVisualizationRepository {
  /// Registra una visualización de video
  Future<Either<Failure, bool>> registerMediaVisualization(MediaVisualization visualization);
}
