import '../../domain/entities/ad.dart';
import 'metadata_json.dart';

/// Modelo de datos para la vista media_library.vw_media_files_with_posters de Supabase
class AdModel extends Ad {
  const AdModel({
    required super.id,
    required super.title,
    required super.description,
    required super.videoUrl,
    required super.createdAt,
    required super.mediaType,
    required super.mediaMimeType,
    super.thumbnailUrl,
    super.categoryId,
    super.categoryName,
    super.categoryImageUrl,
    super.posterCreatedAt,
    super.posterTitle,
    super.metadata,
  });

  /// Crea una instancia desde un mapa de datos (JSON de Supabase)
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['media_file_id'] ?? '',
      title: json['media_title'] ?? '',
      description: json['file_description'] ?? '',
      videoUrl: json['media_url'] ?? '',
      thumbnailUrl: json['poster_url'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      categoryImageUrl: json['category_image_url'],
      createdAt: json['media_created_at'] != null
          ? DateTime.parse(json['media_created_at'])
          : DateTime.now(),
      posterCreatedAt: json['poster_created_at'] != null
          ? DateTime.parse(json['poster_created_at'])
          : null,
      mediaType: json['media_type'] ?? '',
      mediaMimeType: json['media_mime_type'] ?? '',
      posterTitle: json['poster_title'],
      metadata: json['metadata_json'] != null
          ? MetadataJson.fromJson(json['metadata_json'])
          : null,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'media_file_id': id,
      'media_title': title,
      'file_description': description,
      'media_url': videoUrl,
      'poster_url': thumbnailUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_image_url': categoryImageUrl,
      'media_created_at': createdAt.toIso8601String(),
      'poster_created_at': posterCreatedAt?.toIso8601String(),
      'media_type': mediaType,
      'media_mime_type': mediaMimeType,
      'poster_title': posterTitle,
      'metadata_json': metadata?.toJson(),
    };
  }

  /// Crea una copia con algunos campos modificados
  @override
  AdModel copyWith({
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
    MetadataJson? metadata,
  }) {
    return AdModel(
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
      metadata: metadata ?? this.metadata,
    );
  }
}
