import '../../domain/entities/genre.dart';

/// Modelo de datos para la tabla genre_ads de Supabase
class GenreModel extends Genre {
  const GenreModel({
    required super.id,
    required super.name,
    required super.posterImg, required super.createdAt, super.description,
    super.posterImgFile,
    super.visible = true,
    super.updatedAt,
  });

  /// Crea una instancia desde un mapa de datos (JSON de Supabase)
  factory GenreModel.fromJson(Map<String, dynamic> json) {
    return GenreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      posterImg:
          json['poster_img'] ??
          'https://u-supabase.virtalus.cbluna-dev.com/storage/v1/object/public/assets/placeholder_no_image.jpg',
      posterImgFile: json['poster_img_file'],
      visible: json['visible'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'poster_img': posterImg,
      'poster_img_file': posterImgFile,
      'visible': visible,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Crea una copia con algunos campos modificados
  @override
  GenreModel copyWith({
    int? id,
    String? name,
    String? description,
    String? posterImg,
    String? posterImgFile,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GenreModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      posterImg: posterImg ?? this.posterImg,
      posterImgFile: posterImgFile ?? this.posterImgFile,
      visible: visible ?? this.visible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
