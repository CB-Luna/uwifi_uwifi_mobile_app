import 'package:equatable/equatable.dart';

import '../../domain/entities/ad.dart';
import '../../domain/entities/genre_with_videos.dart';

abstract class VideosState extends Equatable {
  const VideosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del BLoC de videos
class VideosInitial extends VideosState {
  const VideosInitial();
}

/// Estado que indica que los datos están siendo cargados
class VideosLoading extends VideosState {
  const VideosLoading();
}

/// Estado que contiene los videos cargados
class VideosLoaded extends VideosState {
  final List<Ad> videos;
  final bool hasReachedEnd;
  final int currentPage;
  final int? currentCategory;
  final int? userPoints;
  final bool isRandomMode;

  const VideosLoaded({
    required this.videos,
    this.hasReachedEnd = false,
    this.currentPage = 1,
    this.currentCategory,
    this.userPoints,
    this.isRandomMode = false,
  });

  @override
  List<Object?> get props => [
    videos,
    hasReachedEnd,
    currentPage,
    currentCategory,
    userPoints,
    isRandomMode,
  ];

  VideosLoaded copyWith({
    List<Ad>? videos,
    bool? hasReachedEnd,
    int? currentPage,
    int? currentCategory,
    int? userPoints,
    bool? isRandomMode,
  }) {
    return VideosLoaded(
      videos: videos ?? this.videos,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      currentCategory: currentCategory ?? this.currentCategory,
      userPoints: userPoints ?? this.userPoints,
      isRandomMode: isRandomMode ?? this.isRandomMode,
    );
  }
}

/// Estado específico para cuando se actualizan los puntos del usuario
class VideosLoadedState extends VideosLoaded {
  const VideosLoadedState({
    required super.videos,
    super.hasReachedEnd,
    super.currentPage,
    super.currentCategory,
    super.userPoints,
    super.isRandomMode,
  });
}

/// Estado que contiene los videos agrupados por categoría/género
class VideosByGenreLoaded extends VideosState {
  final List<GenreWithVideos> genreWithVideos;

  const VideosByGenreLoaded({required this.genreWithVideos});

  @override
  List<Object?> get props => [genreWithVideos];
}

/// Estado que contiene un solo video
class VideoLoaded extends VideosState {
  final Ad video;

  const VideoLoaded({required this.video});

  @override
  List<Object?> get props => [video];
}

/// Estado que indica un error en la carga de videos
class VideosError extends VideosState {
  final String message;

  const VideosError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado que indica que los puntos están siendo procesados
class PointsProcessing extends VideosState {
  final String action;

  const PointsProcessing({required this.action});

  @override
  List<Object?> get props => [action];
}

/// Estado que indica que los puntos fueron actualizados exitosamente
class PointsUpdated extends VideosState {
  final int newTotal;
  final int pointsChanged;
  final String reason;

  const PointsUpdated({
    required this.newTotal,
    required this.pointsChanged,
    required this.reason,
  });

  @override
  List<Object?> get props => [newTotal, pointsChanged, reason];
}

/// Estado que indica un error en el manejo de puntos
class PointsError extends VideosState {
  final String message;

  const PointsError({required this.message});

  @override
  List<Object?> get props => [message];
}
