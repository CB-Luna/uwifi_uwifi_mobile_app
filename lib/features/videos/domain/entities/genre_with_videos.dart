import 'package:equatable/equatable.dart';

import 'ad.dart';

/// Entidad que representa una categoría con sus videos asociados
class GenreWithVideos extends Equatable {
  final int id; // ID de la categoría (media_categories_id)
  final String name; // Nombre de la categoría (category_name)
  final String?
  description; // Descripción de la categoría (category_description)
  final String posterImg; // URL de la imagen de portada
  final int totalVideos; // Número total de videos en esta categoría
  final List<Ad> videos; // Lista de videos en esta categoría

  const GenreWithVideos({
    required this.id,
    required this.name,
    required this.posterImg,
    required this.totalVideos,
    required this.videos,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    posterImg,
    totalVideos,
    videos,
  ];
}
