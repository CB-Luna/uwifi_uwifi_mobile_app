import '../models/media_visualization_model.dart';

/// Fuente de datos remota para manejar las visualizaciones de medios
abstract class MediaVisualizationRemoteDataSource {
  /// Registra una visualización de video en la base de datos
  /// 
  /// Retorna `true` si la operación fue exitosa
  Future<bool> registerMediaVisualization(MediaVisualizationModel visualization);
}
