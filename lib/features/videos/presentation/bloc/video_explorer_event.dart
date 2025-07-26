import 'package:equatable/equatable.dart';

/// Eventos para el explorador de videos
abstract class VideoExplorerEvent extends Equatable {
  const VideoExplorerEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar categorías disponibles
class LoadCategoriesEvent extends VideoExplorerEvent {
  const LoadCategoriesEvent();
}

/// Filtrar videos por categoría
class FilterByCategory extends VideoExplorerEvent {
  final int? categoryId;
  final String categoryName;
  final bool clearCache;

  const FilterByCategory({
    required this.categoryName, this.categoryId,
    this.clearCache = false,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, clearCache];
}

/// Buscar videos por texto
class SearchVideosEvent extends VideoExplorerEvent {
  final String query;

  const SearchVideosEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Cargar más videos (paginación)
class LoadMoreVideosEvent extends VideoExplorerEvent {
  const LoadMoreVideosEvent();
}

/// Refrescar videos
class RefreshVideosEvent extends VideoExplorerEvent {
  const RefreshVideosEvent();
}

/// Seleccionar video para reproducir
class SelectVideoEvent extends VideoExplorerEvent {
  final String videoId;
  final int startIndex;

  const SelectVideoEvent({required this.videoId, required this.startIndex});

  @override
  List<Object?> get props => [videoId, startIndex];
}

/// Limpiar filtros
class ClearFiltersEvent extends VideoExplorerEvent {
  const ClearFiltersEvent();
}
