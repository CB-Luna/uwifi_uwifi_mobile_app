import 'package:equatable/equatable.dart';
import '../../domain/entities/ad.dart';
import '../../domain/entities/genre_with_videos.dart';

/// Estados del explorador de videos
abstract class VideoExplorerState extends Equatable {
  const VideoExplorerState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class VideoExplorerInitial extends VideoExplorerState {
  const VideoExplorerInitial();
}

/// Cargando datos iniciales
class VideoExplorerLoading extends VideoExplorerState {
  const VideoExplorerLoading();
}

/// Datos cargados exitosamente
class VideoExplorerLoaded extends VideoExplorerState {
  final List<GenreWithVideos> categories;
  final List<Ad> videos;
  final List<Ad> filteredVideos;
  final GenreWithVideos? selectedCategory;
  final String searchQuery;
  final bool isLoadingMore;
  final bool hasMoreVideos;
  final int currentPage;
  final bool isRefreshing;

  const VideoExplorerLoaded({
    required this.categories,
    required this.videos,
    required this.filteredVideos,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.hasMoreVideos = true,
    this.currentPage = 1,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    categories,
    videos,
    filteredVideos,
    selectedCategory,
    searchQuery,
    isLoadingMore,
    hasMoreVideos,
    currentPage,
    isRefreshing,
  ];

  VideoExplorerLoaded copyWith({
    List<GenreWithVideos>? categories,
    List<Ad>? videos,
    List<Ad>? filteredVideos,
    GenreWithVideos? selectedCategory,
    String? searchQuery,
    bool? isLoadingMore,
    bool? hasMoreVideos,
    int? currentPage,
    bool? isRefreshing,
    bool clearCategory = false,
  }) {
    return VideoExplorerLoaded(
      categories: categories ?? this.categories,
      videos: videos ?? this.videos,
      filteredVideos: filteredVideos ?? this.filteredVideos,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      currentPage: currentPage ?? this.currentPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error al cargar datos
class VideoExplorerError extends VideoExplorerState {
  final String message;
  final String? errorCode;

  const VideoExplorerError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

/// Video seleccionado para reproducir
class VideoSelectedForPlayback extends VideoExplorerState {
  final Ad selectedVideo;
  final List<Ad> playlist;
  final int startIndex;

  const VideoSelectedForPlayback({
    required this.selectedVideo,
    required this.playlist,
    required this.startIndex,
  });

  @override
  List<Object?> get props => [selectedVideo, playlist, startIndex];
}
