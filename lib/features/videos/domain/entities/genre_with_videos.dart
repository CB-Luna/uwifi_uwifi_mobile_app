import 'package:equatable/equatable.dart';
import 'ad.dart';

/// Entidad que representa un género con sus videos asociados
class GenreWithVideos extends Equatable {
  final int id; // Añadido campo id
  final String name;
  final String posterImg;
  final String? posterImgFile;
  final int totalVideos;
  final List<Ad> videos;

  const GenreWithVideos({
    required this.id, // Añadido campo id
    required this.name,
    required this.posterImg,
    required this.totalVideos, required this.videos, this.posterImgFile,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    posterImg,
    posterImgFile,
    totalVideos,
    videos,
  ];
}
