import '../../domain/entities/ad.dart';

/// Modelo de datos para la tabla ad de Supabase
class AdModel extends Ad {
  const AdModel({
    required super.id,
    required super.title,
    required super.description,
    required super.videoUrl, required super.genreId, required super.priority, required super.createdAt, super.overview = '',
    super.thumbnailUrl,
    super.updatedAt,
    super.visible = true,
    super.liked = false,
    super.views = 0,
    super.duration = 0,
    super.durationVideo = 0,
    super.points = 0,
  });

  /// Crea una instancia desde un mapa de datos (JSON de Supabase)
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      overview: json['overview'] ?? '', // Campo overview de Supabase
      videoUrl:
          json['video'] ?? '', // ✅ CORRECCIÓN: Cambiar de 'video_url' a 'video'
      thumbnailUrl:
          json['poster_path'], // ✅ CORRECCIÓN: Usar poster_path de la BD
      genreId: json['genre_id'] ?? 0,
      priority: json['priority'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      visible: json['visible'] ?? true,
      liked: json['liked'] ?? false,
      views: json['views'] ?? 0,
      duration: json['duration'] ?? 0,
      durationVideo:
          json['duration_video'] ?? 0, // Campo duration_video de Supabase
      points: json['points'] ?? 0, // Campo points de Supabase
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'overview': overview,
      'video':
          videoUrl, // Usar 'video' en lugar de 'video_url' para consistencia
      'thumbnail_url': thumbnailUrl,
      'genre_id': genreId,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'visible': visible,
      'liked': liked,
      'views': views,
      'duration': duration,
      'duration_video': durationVideo,
      'points': points,
    };
  }

  /// Crea una copia con algunos campos modificados
  @override
  AdModel copyWith({
    int? id,
    String? title,
    String? description,
    String? overview,
    String? videoUrl,
    String? thumbnailUrl,
    int? genreId,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? visible,
    bool? liked,
    int? views,
    int? duration,
    int? durationVideo,
    int? points,
  }) {
    return AdModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      overview: overview ?? this.overview,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      genreId: genreId ?? this.genreId,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      visible: visible ?? this.visible,
      liked: liked ?? this.liked,
      views: views ?? this.views,
      duration: duration ?? this.duration,
      durationVideo: durationVideo ?? this.durationVideo,
      points: points ?? this.points,
    );
  }
}
