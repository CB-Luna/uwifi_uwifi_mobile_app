import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_video.dart';
import '../../domain/usecases/get_videos.dart';
import '../../domain/usecases/get_videos_by_genre.dart';
import '../../domain/usecases/get_videos_paginated.dart';
import '../../domain/usecases/like_video.dart';
import '../../domain/usecases/mark_video_as_viewed.dart';
import '../../domain/usecases/params.dart';
import '../../domain/usecases/unlike_video.dart';
import 'videos_event.dart';
import 'videos_state.dart';

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  final GetVideos getVideos;
  final GetVideosPaginated getVideosPaginated;
  final GetVideosByGenre getVideosByGenre;
  final GetVideo getVideo;
  final MarkVideoAsViewed markVideoAsViewed;
  final LikeVideo likeVideo;
  final UnlikeVideo unlikeVideo;

  // Variable para almacenar puntos del usuario (en una implementación real vendría de un repositorio)
  int _userPoints = 0;

  VideosBloc({
    required this.getVideos,
    required this.getVideosPaginated,
    required this.getVideosByGenre,
    required this.getVideo,
    required this.markVideoAsViewed,
    required this.likeVideo,
    required this.unlikeVideo,
  }) : super(const VideosInitial()) {
    // Inicializar puntos del usuario
    _userPoints = 100; // Puntos iniciales para testing

    on<LoadVideosEvent>(_onLoadVideos);
    on<LoadVideosPaginatedEvent>(_onLoadVideosPaginated);
    on<LoadVideosByGenreEvent>(_onLoadVideosByGenre);
    on<LoadVideoEvent>(_onLoadVideo);
    on<MarkVideoAsViewedEvent>(_onMarkVideoAsViewed);
    on<LikeVideoEvent>(_onLikeVideo);
    on<UnlikeVideoEvent>(_onUnlikeVideo);
    // Eventos para el sistema de puntos
    on<AddUserPointsEvent>(_onAddUserPoints);
    on<LoadUserPointsEvent>(_onLoadUserPoints);
    on<DeductUserPointsEvent>(_onDeductUserPoints);
    on<CompleteVideoEvent>(_onCompleteVideo);
  }

  Future<void> _onLoadVideos(
    LoadVideosEvent event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosLoading());
    final result = await getVideos(NoParams());

    result.fold(
      (failure) => emit(VideosError(message: _mapFailureToMessage(failure))),
      (videos) => emit(VideosLoaded(videos: videos)),
    );
  }

  Future<void> _onLoadVideosPaginated(
    LoadVideosPaginatedEvent event,
    Emitter<VideosState> emit,
  ) async {
    // Logs de depuración para verificar el ID de categoría
    AppLogger.videoInfo(
      '🔍 Cargando videos paginados - Categoría ID: ${event.categoryId}, Página: ${event.page}',
    );

    // Si es la primera página o estamos cambiando de categoría, mostrar loading
    if (event.page == 1 ||
        (state is VideosLoaded &&
            (state as VideosLoaded).currentCategory != event.categoryId)) {
      emit(const VideosLoading());
    }

    final params = VideosPaginatedParams(
      page: event.page,
      limit: event.limit,
      categoryId: event.categoryId,
    );

    final result = await getVideosPaginated(params);

    result.fold(
      (failure) => emit(VideosError(message: _mapFailureToMessage(failure))),
      (videos) {
        // ✅ CORRECCIÓN: Mejorar la lógica para detectar fin de videos
        // Si no hay videos O se obtuvieron menos videos de los solicitados,
        // significa que hemos llegado al final
        final hasReachedEnd = videos.isEmpty || videos.length < event.limit;

        // If we already had loaded videos and it's not the first page
        if (state is VideosLoaded && event.page > 1) {
          final currentState = state as VideosLoaded;
          final allVideos = [...currentState.videos, ...videos];

          emit(
            VideosLoaded(
              videos: allVideos,
              hasReachedEnd: hasReachedEnd,
              currentPage: event.page,
              currentCategory: event.categoryId,
            ),
          );
        } else {
          // Primera carga
          emit(
            VideosLoaded(
              videos: videos,
              hasReachedEnd: hasReachedEnd,
              currentPage: event.page,
              currentCategory: event.categoryId,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadVideosByGenre(
    LoadVideosByGenreEvent event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosLoading());

    final result = await getVideosByGenre(NoParams());

    result.fold(
      (failure) {
        AppLogger.videoError(
          'Error al cargar videos por género: ${failure.toString()}',
        );
        emit(VideosError(message: _mapFailureToMessage(failure)));
      },
      (genreWithVideos) {
        AppLogger.videoInfo(
          'Videos por género cargados: ${genreWithVideos.length} categorías',
        );
        emit(VideosByGenreLoaded(genreWithVideos: genreWithVideos));
      },
    );
  }

  Future<void> _onLoadVideo(
    LoadVideoEvent event,
    Emitter<VideosState> emit,
  ) async {
    emit(const VideosLoading());

    final result = await getVideo(VideoParams(id: event.videoId));

    result.fold(
      (failure) => emit(VideosError(message: _mapFailureToMessage(failure))),
      (video) => emit(VideoLoaded(video: video)),
    );
  }

  Future<void> _onMarkVideoAsViewed(
    MarkVideoAsViewedEvent event,
    Emitter<VideosState> emit,
  ) async {
    final result = await markVideoAsViewed(VideoParams(id: event.videoId));

    result.fold(
      (failure) {
        // Loguear el error pero no cambiar el estado actual
        AppLogger.videoError(
          'Error al marcar video como visto: ${failure.toString()}',
        );
      },
      (success) {
        // Opcional: actualizar el estado si es necesario
        AppLogger.videoInfo('Video marcado como visto: ${event.videoId}');
      },
    );
  }

  Future<void> _onLikeVideo(
    LikeVideoEvent event,
    Emitter<VideosState> emit,
  ) async {
    final result = await likeVideo(VideoParams(id: event.videoId));

    result.fold(
      (failure) {
        AppLogger.videoError('Error al dar like: ${failure.toString()}');
      },
      (success) {
        AppLogger.videoInfo('Like para video ${event.videoId}');
        // Si el estado actual contiene un video específico
        if (state is VideoLoaded) {
          final currentVideo = (state as VideoLoaded).video;
          if (currentVideo.id == event.videoId) {
            emit(VideoLoaded(video: currentVideo));
          }
        }
      },
    );
  }

  Future<void> _onUnlikeVideo(
    UnlikeVideoEvent event,
    Emitter<VideosState> emit,
  ) async {
    final result = await unlikeVideo(VideoParams(id: event.videoId));

    result.fold(
      (failure) {
        AppLogger.videoError('Error al quitar like: ${failure.toString()}');
      },
      (success) {
        AppLogger.videoInfo('Like removido para video ${event.videoId}');
        // Si el estado actual contiene un video específico
        if (state is VideoLoaded) {
          final currentVideo = (state as VideoLoaded).video;
          if (currentVideo.id == event.videoId) {
            emit(VideoLoaded(video: currentVideo));
          }
        }
      },
    );
  }

  Future<void> _onAddUserPoints(
    AddUserPointsEvent event,
    Emitter<VideosState> emit,
  ) async {
    try {
      emit(PointsProcessing(action: 'Agregando ${event.points} puntos'));

      // Simular delay de procesamiento
      await Future.delayed(const Duration(milliseconds: 300));

      // Agregar puntos al total del usuario
      _userPoints += event.points;

      AppLogger.videoInfo(
        '✨ Puntos agregados: ${event.points}. Total: $_userPoints',
      );

      // Emitir estado de puntos actualizados
      emit(
        PointsUpdated(
          newTotal: _userPoints,
          pointsChanged: event.points,
          reason: event.reason,
        ),
      );

      // Si el estado actual es VideosLoaded, actualizarlo con los nuevos puntos
      if (state is VideosLoaded) {
        final currentState = state as VideosLoaded;
        emit(currentState.copyWith(userPoints: _userPoints));
      }
    } catch (e) {
      emit(PointsError(message: 'Error al agregar puntos: $e'));
    }
  }

  Future<void> _onLoadUserPoints(
    LoadUserPointsEvent event,
    Emitter<VideosState> emit,
  ) async {
    try {
      // En una implementación real, esto vendría de un repositorio/API
      // Por ahora simulamos la carga de puntos
      await Future.delayed(const Duration(milliseconds: 200));

      AppLogger.videoInfo('📊 Puntos del usuario cargados: $_userPoints');

      // Si el estado actual es VideosLoaded, actualizarlo con los puntos
      if (state is VideosLoaded) {
        final currentState = state as VideosLoaded;
        emit(currentState.copyWith(userPoints: _userPoints));
      }
    } catch (e) {
      emit(PointsError(message: 'Error al cargar puntos: $e'));
    }
  }

  Future<void> _onDeductUserPoints(
    DeductUserPointsEvent event,
    Emitter<VideosState> emit,
  ) async {
    try {
      emit(PointsProcessing(action: 'Deduciendo ${event.points} puntos'));

      // Verificar que el usuario tenga suficientes puntos
      if (_userPoints < event.points) {
        emit(const PointsError(message: 'Puntos insuficientes'));
        return;
      }

      // Simular delay de procesamiento
      await Future.delayed(const Duration(milliseconds: 300));

      // Deducir puntos del total del usuario
      _userPoints -= event.points;

      AppLogger.videoInfo(
        '💸 Puntos deducidos: ${event.points}. Total: $_userPoints',
      );

      // Emitir estado de puntos actualizados
      emit(
        PointsUpdated(
          newTotal: _userPoints,
          pointsChanged: -event.points,
          reason: event.reason,
        ),
      );

      // Si el estado actual es VideosLoaded, actualizarlo con los nuevos puntos
      if (state is VideosLoaded) {
        final currentState = state as VideosLoaded;
        emit(currentState.copyWith(userPoints: _userPoints));
      }
    } catch (e) {
      emit(PointsError(message: 'Error al deducir puntos: $e'));
    }
  }

  Future<void> _onCompleteVideo(
    CompleteVideoEvent event,
    Emitter<VideosState> emit,
  ) async {
    try {
      // Marcar video como visto
      final markViewedResult = await markVideoAsViewed(
        VideoParams(id: event.videoId),
      );

      markViewedResult.fold(
        (failure) {
          AppLogger.videoError('Error al marcar video como visto: $failure');
        },
        (success) {
          AppLogger.videoInfo('🎬 Video ${event.videoId} completado');
        },
      );

      // Agregar puntos por completar el video
      add(AddUserPointsEvent(event.earnedPoints, reason: 'Video completado'));
    } catch (e) {
      emit(PointsError(message: 'Error al completar video: $e'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Error de servidor';
      case CacheFailure _:
        return 'Error de caché';
      case NetworkFailure _:
        return 'No hay conexión a internet';
      default:
        return 'Error inesperado';
    }
  }
}
