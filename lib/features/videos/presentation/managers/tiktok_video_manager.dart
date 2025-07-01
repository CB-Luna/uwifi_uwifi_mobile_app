import 'package:flutter/material.dart';
import '../../domain/entities/ad.dart';
import '../../../../core/utils/app_logger.dart';

/// Manager simplificado para coordinar videos estilo TikTok
/// Reemplaza toda la lógica compleja anterior con una implementación eficiente
class TikTokVideoManager extends ChangeNotifier {
  // ✅ CORRECCIÓN: Eliminar controlador duplicado, solo coordinar
  // final SimpleTikTokVideoController _videoController = SimpleTikTokVideoController();

  List<Ad> _videos = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Ad> get videos => _videos;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Ad? get currentVideo => _videos.isNotEmpty ? _videos[_currentIndex] : null;
  // ✅ CORRECCIÓN: Eliminar referencia al controlador duplicado
  // SimpleTikTokVideoController get videoController => _videoController;

  /// Actualiza la lista de videos
  void updateVideos(List<Ad> videos) {
    // ✅ EVITAR ACTUALIZACIONES INNECESARIAS - Verificar si realmente hay cambios
    if (_videos.length == videos.length &&
        _videos.isNotEmpty &&
        videos.isNotEmpty &&
        _videos.first.id == videos.first.id &&
        _videos.last.id == videos.last.id) {
      AppLogger.videoInfo('📋 Videos already up to date, skipping update');
      return;
    }

    // ✅ CORRECCIÓN: Preservar el índice actual cuando se agregan nuevos videos
    final previousCurrentVideoId = currentVideo?.id;
    final isAddingMoreVideos =
        videos.length > _videos.length && _videos.isNotEmpty;

    AppLogger.videoInfo('📥 TikTok Manager: Updating ${videos.length} videos');

    // ✅ DIAGNÓSTICO: Mostrar detalles de los videos recibidos
    for (int i = 0; i < videos.length && i < 3; i++) {
      AppLogger.videoInfo(
        '  📹 Video $i: "${videos[i].title}" (ID: ${videos[i].id})',
      );
    }
    if (videos.length > 3) {
      AppLogger.videoInfo('  ... and ${videos.length - 3} more videos');
    }

    // ✅ Agrupar cambios para evitar múltiples notificaciones
    bool shouldNotify = false;

    // ✅ CORRECCIÓN CRÍTICA: No limitar videos y preservar el índice actual
    if (_videos != videos) {
      _videos = videos;
      shouldNotify = true;
    }

    // ✅ Preservar la posición actual del video si estamos agregando más videos
    if (isAddingMoreVideos && previousCurrentVideoId != null) {
      final newIndex = _videos.indexWhere(
        (video) => video.id == previousCurrentVideoId,
      );
      if (newIndex != -1 && _currentIndex != newIndex) {
        _currentIndex = newIndex;
        AppLogger.videoInfo(
          '🎯 Preserved current video position at index $_currentIndex',
        );
        shouldNotify = true;
      }
    } else if (_currentIndex != 0) {
      _currentIndex = 0;
      shouldNotify = true;
    }

    if (_error != null) {
      _error = null;
      shouldNotify = true;
    }

    if (_videos.isNotEmpty) {
      _loadCurrentVideo();
    }

    // ✅ Solo notificar si realmente hay cambios y hay listeners activos
    if (shouldNotify && hasListeners) {
      notifyListeners();
    }
  }

  /// Cambia al video en el índice especificado
  Future<void> goToVideo(int index) async {
    if (index < 0 || index >= _videos.length) {
      AppLogger.videoWarning('⚠️ Invalid video index: $index');
      return;
    }

    if (_currentIndex == index) {
      AppLogger.videoInfo('📍 Already at video $index');
      return;
    }

    AppLogger.videoInfo('🎯 Moving to video $index');

    // ✅ Agrupar cambios para evitar múltiples notificaciones
    bool shouldNotify = false;

    if (_currentIndex != index) {
      _currentIndex = index;
      shouldNotify = true;
    }

    if (_error != null) {
      _error = null;
      shouldNotify = true;
    }

    // ✅ Solo notificar si realmente hay cambios y hay listeners activos
    if (shouldNotify && hasListeners) {
      notifyListeners();
    }
  }

  /// Va al siguiente video
  Future<void> nextVideo() async {
    final nextIndex = (_currentIndex + 1) % _videos.length;
    await goToVideo(nextIndex);
  }

  /// Va al video anterior
  Future<void> previousVideo() async {
    final previousIndex = _currentIndex > 0
        ? _currentIndex - 1
        : _videos.length - 1;
    await goToVideo(previousIndex);
  }

  /// Carga el video actual
  Future<void> _loadCurrentVideo() async {
    if (_videos.isEmpty) return;

    final video = _videos[_currentIndex];
    _setLoading(true);

    try {
      // ✅ CORRECCIÓN: Solo logging, el TikTokVideoPlayer manejará la reproducción
      AppLogger.videoInfo('✅ Video coordinated: ${video.title}');
      _error = null;
    } catch (e) {
      _error = 'Error coordinating video: $e';
      AppLogger.videoError('💥 Exception coordinating video: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Maneja el like de un video
  void likeVideo(int videoId) {
    final videoIndex = _videos.indexWhere((v) => v.id == videoId);
    if (videoIndex != -1) {
      AppLogger.videoInfo('❤️ Liked video: $videoId');
      // ✅ Solo notificar si hay listeners activos
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// Obtiene estadísticas del manager
  Map<String, dynamic> getStats() {
    return {
      'totalVideos': _videos.length,
      'currentIndex': _currentIndex,
      'isLoading': _isLoading,
      'hasError': _error != null,
    };
  }

  void _setLoading(bool loading) {
    // ✅ Solo notificar si el estado realmente cambió y no está disposed
    if (_isLoading != loading) {
      _isLoading = loading;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  /// Limpia recursos
  @override
  void dispose() {
    AppLogger.videoInfo('🧹 TikTok Manager: Disposing resources');
    // ✅ CORRECCIÓN: Solo limpiar recursos del manager, no controlador duplicado
    super.dispose();
  }
}
