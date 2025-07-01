import 'package:equatable/equatable.dart';

/// Parámetros para obtener un video específico por ID
class VideoParams extends Equatable {
  final int id;

  const VideoParams({required this.id});

  @override
  List<Object> get props => [id];
}

/// Parámetros para obtener videos paginados
class VideosPaginatedParams extends Equatable {
  final int page;
  final int limit;
  final int? categoryId;

  const VideosPaginatedParams({
    required this.page,
    this.limit = 10,
    this.categoryId,
  });

  @override
  List<Object?> get props => [page, limit, categoryId];
}
