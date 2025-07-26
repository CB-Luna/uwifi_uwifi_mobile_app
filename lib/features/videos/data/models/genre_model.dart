import '../../domain/entities/genre.dart';

/// Modelo de datos para la tabla media_categories de Supabase
class GenreModel extends Genre {
  const GenreModel({
    required super.id,
    required super.name,
    required super.posterImg,
    required super.createdAt,
    super.description,
    super.mediaFileFK,
    super.createdBy,
    super.visible = true,
  });

  /// Crea una instancia desde un mapa de datos (JSON de Supabase)
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['media_categories_id'] ?? 0,
      name: json['category_name'] ?? '',
      description: json['category_description'],
      mediaFileFK: json['media_file_fk'],
      createdBy: json['created_by'],
      // Usamos una imagen por defecto para mantener compatibilidad con la UI
      posterImg: 'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
      visible: true, // Mantenemos visible por defecto para compatibilidad
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'media_categories_id': id,
      'category_name': name,
      'category_description': description,
      'media_file_fk': mediaFileFK,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crea una copia con algunos campos modificados
  @override
  GenreModel copyWith({
    int? id,
    String? name,
    String? description,
    String? mediaFileFK,
    String? createdBy,
    String? posterImg,
    bool? visible,
    DateTime? createdAt,
  }) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mediaFileFK: mediaFileFK ?? this.mediaFileFK,
      createdBy: createdBy ?? this.createdBy,
      posterImg: posterImg ?? this.posterImg,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
