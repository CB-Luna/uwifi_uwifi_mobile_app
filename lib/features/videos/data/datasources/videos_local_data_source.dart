import '../models/ad_model.dart';

abstract class VideosLocalDataSource {
  /// Obtiene los últimos videos cacheados
  Future<List<AdModel>> getLastVideos();

  /// Guarda videos en caché
  Future<void> cacheVideos(List<AdModel> videos);

  /// Obtiene un video específico de la caché
  Future<AdModel> getVideo(String id);
}
