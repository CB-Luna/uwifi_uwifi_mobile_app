import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/entities/genre_with_videos.dart';
import '../../domain/entities/ad.dart';
import 'ad_model.dart';

/// Modelo de datos para representar la vista group_ad_by_genre de Supabase
class GenreWithVideosModel extends GenreWithVideos {
  const GenreWithVideosModel({
    required super.id,
    required super.name,
    super.description,
    required super.posterImg,
    required super.totalVideos,
    required super.videos,
  });

  /// Crea una instancia desde un mapa de datos (JSON)
  factory GenreWithVideosModel.fromJson(Map<String, dynamic> json) {
    // Parsear la lista de videos desde el JSON
    List<Ad> videos = [];
    if (json['videos'] != null) {
      final List<dynamic> videosList = json['videos'] is String
          ? jsonDecode(json['videos'])
          : json['videos'];

      videos = videosList
          .map((videoJson) => AdModel.fromJson(videoJson))
          .cast<Ad>()
          .toList();
    }

    // Obtener el ID de la categoría
    int categoryId;
    String source = 'desconocido';

    if (json.containsKey('id') && json['id'] != null) {
      // Usar el campo id directamente
      categoryId = json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0;
      source = 'campo id';
    } else if (json.containsKey('media_categories_id') && json['media_categories_id'] != null) {
      // Alternativa: usar media_categories_id si está disponible
      categoryId = json['media_categories_id'] is int
          ? json['media_categories_id']
          : int.tryParse(json['media_categories_id'].toString()) ?? 0;
      source = 'campo media_categories_id';
    } else if (json.containsKey('category_id') && json['category_id'] != null) {
      // Alternativa: usar category_id si está disponible
      categoryId = json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString()) ?? 0;
      source = 'campo category_id';
    } else {
      // Fallback
      categoryId = 0;
      source = 'fallback';
    }

    // Obtener el nombre de la categoría
    final String categoryName = json['name'] ?? json['category_name'] ?? 'Sin nombre';
    debugPrint(
      '📊 Categoría cargada: $categoryName con ID: $categoryId (fuente: $source)',
    );

    // Mostrar advertencia si el ID es 0 (posible error)
    if (categoryId == 0) {
      String jsonPreview = json.toString();
      if (jsonPreview.length > 200) {
        jsonPreview = '${jsonPreview.substring(0, 200)}...';
      }
      debugPrint(
        '⚠️ ADVERTENCIA: ID de categoría 0 para $categoryName. JSON: $jsonPreview',
      );
    }

    return GenreWithVideosModel(
      id: categoryId,
      name: categoryName,
      description: json['description'] ?? json['category_description'],
      posterImg: json['poster_img'] ?? 
                json['category_image_url'] ?? 
                'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
      totalVideos: videos.length,
      videos: videos,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'media_categories_id': id,
      'name': name,
      'category_name': name,
      'description': description,
      'category_description': description,
      'poster_img': posterImg,
      'category_image_url': posterImg,
      'total_videos': totalVideos,
      'videos': videos.map((video) {
        if (video is AdModel) {
          return video.toJson();
        }
        // Si no es un AdModel, intentamos crear una representación genérica
        return {'media_file_id': video.id, 'media_title': video.title};
      }).toList(),
    };
  }
}
