import 'package:equatable/equatable.dart';

abstract class VideosEvent extends Equatable {
  const VideosEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todos los videos
class LoadVideosEvent extends VideosEvent {
  const LoadVideosEvent();
}

/// Evento para cargar videos paginados con soporte para filtrar por categoría
class LoadVideosPaginatedEvent extends VideosEvent {
  final int page;
  final int limit;
  final int? categoryId;

  const LoadVideosPaginatedEvent({
    this.page = 1,
    this.limit = 10,
    this.categoryId,
  });

  @override
  List<Object?> get props => [page, limit, categoryId];
}

/// Evento para cargar videos agrupados por género/categoría
class LoadVideosByGenreEvent extends VideosEvent {
  const LoadVideosByGenreEvent();
}

/// Evento para cargar un video específico
class LoadVideoEvent extends VideosEvent {
  final String videoId;

  const LoadVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Evento para marcar un video como visto
class MarkVideoAsViewedEvent extends VideosEvent {
  final String videoId;

  const MarkVideoAsViewedEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Evento para dar "me gusta" a un video
class LikeVideoEvent extends VideosEvent {
  final String videoId;

  const LikeVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Evento para quitar el "me gusta" de un video
class UnlikeVideoEvent extends VideosEvent {
  final String videoId;

  const UnlikeVideoEvent(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

/// Evento para agregar puntos al usuario
class AddUserPointsEvent extends VideosEvent {
  final int points;
  final String reason;

  const AddUserPointsEvent(this.points, {this.reason = 'Video completion'});

  @override
  List<Object?> get props => [points, reason];
}

/// Evento para cargar los puntos actuales del usuario
class LoadUserPointsEvent extends VideosEvent {
  const LoadUserPointsEvent();
}

/// Evento para restar puntos del usuario (para compras, etc.)
class DeductUserPointsEvent extends VideosEvent {
  final int points;
  final String reason;

  const DeductUserPointsEvent(this.points, {this.reason = 'Purchase'});

  @override
  List<Object?> get props => [points, reason];
}

/// Evento para marcar un video como completado y ganar puntos
class CompleteVideoEvent extends VideosEvent {
  final String videoId;
  final int earnedPoints;

  const CompleteVideoEvent(this.videoId, this.earnedPoints);

  @override
  List<Object?> get props => [videoId, earnedPoints];
}
