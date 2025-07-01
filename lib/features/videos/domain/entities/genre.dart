import 'package:equatable/equatable.dart';

/// Entidad que representa una categoría/género en el dominio
class Genre extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String posterImg;
  final String? posterImgFile;
  final bool visible;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Genre({
    required this.id,
    required this.name,
    required this.posterImg, required this.createdAt, this.description,
    this.posterImgFile,
    this.visible = true,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    posterImg,
    posterImgFile,
    visible,
    createdAt,
    updatedAt,
  ];

  /// Crea una copia con algunos campos modificados
  Genre copyWith({
    int? id,
    String? name,
    String? description,
    String? posterImg,
    String? posterImgFile,
    bool? visible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Genre(
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
