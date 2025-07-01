import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../domain/entities/genre_with_videos.dart';
import '../../domain/entities/ad.dart';
import 'ad_model.dart';

/// Modelo de datos para representar la vista group_ad_by_genre de Supabase
class GenreWithVideosModel extends GenreWithVideos {
  const GenreWithVideosModel({
    required super.id,
    required super.name,
    required super.posterImg,
    required super.totalVideos, required super.videos, super.posterImgFile,
  });

  /// Crea una instancia desde un mapa de datos (JSON)
  factory GenreWithVideosModel.fromJson(Map<String, dynamic> json) {
    // Parsear la lista de videos desde el JSON
    List<Ad> videos = [];
    if (json['ad_video'] != null) {
      final List<dynamic> videosList = json['ad_video'] is String
          ? jsonDecode(json['ad_video'])
          : json['ad_video'];

      videos = videosList
          .map((videoJson) => AdModel.fromJson(videoJson))
          .cast<Ad>()
          .toList();
    }

    // Obtener el ID directamente del campo id en el JSON
    // Si no existe, intentar obtenerlo del campo genre_id o usar 0 como fallback
    int genreId;
    String source = 'desconocido';

    if (json.containsKey('id') && json['id'] != null) {
      // Usar el campo id directamente
      genreId = json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0;
      source = 'campo id';
    } else if (json.containsKey('genre_id') && json['genre_id'] != null) {
      // Alternativa: usar genre_id si está disponible
      genreId = json['genre_id'] is int
          ? json['genre_id']
          : int.tryParse(json['genre_id'].toString()) ?? 0;
      source = 'campo genre_id';
    } else if (videos.isNotEmpty && videos[0] is AdModel) {
      // Último recurso: extraer del primer video
      final firstVideo = videos[0] as AdModel;
      final videoJson = firstVideo.toJson();
      genreId = videoJson['genre_id'] ?? 0;
      source = 'primer video';
    } else {
      // Fallback
      genreId = 0;
      source = 'fallback';
    }

    final String genreName = json['name'] ?? 'Sin nombre';
    debugPrint(
      '📊 Género cargado: $genreName con ID: $genreId (fuente: $source)',
    );

    // Mostrar advertencia si el ID es 0 (posible error)
    if (genreId == 0) {
      String jsonPreview = json.toString();
      if (jsonPreview.length > 200) {
        jsonPreview = '${jsonPreview.substring(0, 200)}...';
      }
      debugPrint(
        '⚠️ ADVERTENCIA: ID de género 0 para $genreName. JSON: $jsonPreview',
      );
    }

    // Imprimir para depuración
    debugPrint('📊 Género cargado: ${json['name']} con ID: $genreId');
    if (genreId == 0 && json['name'] != 'Todas las categorías') {
      debugPrint(
        '⚠️ ADVERTENCIA: ID de género 0 para ${json['name']}. JSON: ${json.toString().substring(0, min(100, json.toString().length))}...',
      );
    }

    return GenreWithVideosModel(
      id: genreId,
      name: json['name'] ?? '',
      posterImg:
          json['poster_img'] ??
          'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
      posterImgFile: json['poster_img_file'],
      totalVideos: json['total_videos'] is int
          ? json['total_videos']
          : int.tryParse(json['total_videos']?.toString() ?? '0') ?? 0,
      videos: videos,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'poster_img': posterImg,
      'poster_img_file': posterImgFile,
      'total_videos': totalVideos,
      'ad_video': videos.map((video) {
        if (video is AdModel) {
          return video.toJson();
        }
        // Si no es un AdModel, intentamos crear una representación genérica
        return {'id': video.id, 'title': video.title};
      }).toList(),
    };
  }
}
