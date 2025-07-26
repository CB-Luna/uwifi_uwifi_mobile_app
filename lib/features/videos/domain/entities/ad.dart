import 'package:equatable/equatable.dart';

/// Entidad que representa un video/anuncio en el dominio
class Ad extends Equatable {
  final String id; // Ahora es UUID (media_file_id)
  final String title; // media_title
  final String description; // file_description
  final String videoUrl; // media_url
  final String? thumbnailUrl; // poster_url
  final int? categoryId; // category_id
  final String? categoryName; // category_name
  final String? categoryImageUrl; // category_image_url
  final DateTime createdAt; // media_created_at
  final DateTime? posterCreatedAt; // poster_created_at
  final String mediaType; // media_type
  final String mediaMimeType; // media_mime_type
  final String? posterTitle; // poster_title
  final bool liked; // Mantenemos este campo para compatibilidad

  const Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.createdAt,
    required this.mediaType,
    required this.mediaMimeType,
    this.thumbnailUrl,
    this.categoryId,
    this.categoryName,
    this.categoryImageUrl,
    this.posterCreatedAt,
    this.posterTitle,
    this.liked = false,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    videoUrl,
    thumbnailUrl,
    categoryId,
    categoryName,
    categoryImageUrl,
    createdAt,
    posterCreatedAt,
    mediaType,
    mediaMimeType,
    posterTitle,
    liked,
  ];

  /// Crea una copia con algunos campos modificados
  Ad copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    int? categoryId,
    String? categoryName,
    String? categoryImageUrl,
    DateTime? createdAt,
    DateTime? posterCreatedAt,
    String? mediaType,
    String? mediaMimeType,
    String? posterTitle,
    bool? liked,
  }) {
    return Ad(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryImageUrl: categoryImageUrl ?? this.categoryImageUrl,
      createdAt: createdAt ?? this.createdAt,
      posterCreatedAt: posterCreatedAt ?? this.posterCreatedAt,
      mediaType: mediaType ?? this.mediaType,
      mediaMimeType: mediaMimeType ?? this.mediaMimeType,
      posterTitle: posterTitle ?? this.posterTitle,
      liked: liked ?? this.liked,
    );
  }
}
