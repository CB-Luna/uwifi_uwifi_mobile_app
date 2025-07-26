import 'package:equatable/equatable.dart';

/// Entidad que representa una categoría/género en el dominio
/// Ahora basada en la tabla media_categories del esquema media_library
class Genre extends Equatable {
  final int id; // media_categories_id
  final String name; // category_name
  final String? description; // category_description
  final String? mediaFileFK; // media_file_fk (UUID)
  final String? createdBy; // created_by (UUID)
  final DateTime createdAt;
  
  // Campos mantenidos para compatibilidad con UI existente
  final String posterImg;
  final bool visible;

  const Genre({
    required this.id,
    required this.name,
    required this.posterImg,
    required this.createdAt,
    this.description,
    this.mediaFileFK,
    this.createdBy,
    this.visible = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    mediaFileFK,
    createdBy,
    posterImg,
    visible,
    createdAt,
  ];

  /// Crea una copia con algunos campos modificados
  Genre copyWith({
    int? id,
    String? name,
    String? description,
    String? mediaFileFK,
    String? createdBy,
    String? posterImg,
    bool? visible,
    DateTime? createdAt,
  }) {
    return Genre(
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
