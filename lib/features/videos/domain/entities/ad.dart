import 'package:equatable/equatable.dart';

/// Entidad que representa un video/anuncio en el dominio
class Ad extends Equatable {
  final int id;
  final String title;
  final String description; // Campo description de Supabase
  final String overview; // Campo overview de Supabase
  final String videoUrl;
  final String? thumbnailUrl;
  final int genreId;
  final int priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool visible;
  final bool liked;
  final int views;
  final int duration; // duración en segundos (campo duration)
  final int durationVideo; // duración del video (campo duration_video)
  final int points; // puntos del video (campo points)

  const Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl, required this.genreId, required this.priority, required this.createdAt, this.overview = '',
    this.thumbnailUrl,
    this.updatedAt,
    this.visible = true,
    this.liked = false,
    this.views = 0,
    this.duration = 0,
    this.durationVideo = 0,
    this.points = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    overview,
    videoUrl,
    thumbnailUrl,
    genreId,
    priority,
    createdAt,
    updatedAt,
    visible,
    liked,
    views,
    duration,
    durationVideo,
    points,
  ];

  /// Crea una copia con algunos campos modificados
  Ad copyWith({
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
    return Ad(
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
