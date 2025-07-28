import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/features/videos/domain/usecases/has_user_liked_video.dart';
import 'package:uwifiapp/features/videos/domain/usecases/like_video_with_customer.dart';
import 'package:uwifiapp/features/videos/domain/usecases/unlike_video_with_customer.dart';
import 'package:uwifiapp/features/videos/presentation/bloc/video_likes_event.dart';
import 'package:uwifiapp/features/videos/presentation/bloc/video_likes_state.dart';

class VideoLikesBloc extends Bloc<VideoLikesEvent, VideoLikesState> {
  final LikeVideoWithCustomer likeVideo;
  final UnlikeVideoWithCustomer unlikeVideo;
  final HasUserLikedVideo hasUserLikedVideo;

  VideoLikesBloc({
    required this.likeVideo,
    required this.unlikeVideo,
    required this.hasUserLikedVideo,
  }) : super(const VideoLikesInitial()) {
    on<LikeVideoEvent>(_onLikeVideo);
    on<UnlikeVideoEvent>(_onUnlikeVideo);
    on<CheckVideoLikeStatusEvent>(_onCheckVideoLikeStatus);
  }

  Future<void> _onLikeVideo(
    LikeVideoEvent event,
    Emitter<VideoLikesState> emit,
  ) async {
    emit(const VideoLikesLoading());
    
    AppLogger.navInfo(
      'Dando like al video ${event.videoId} por el cliente ${event.customerId}',
    );
    
    final params = LikeVideoParams(
      customerId: event.customerId,
      videoId: event.videoId,
    );
    
    final result = await likeVideo(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al dar like: ${failure.toString()}');
        emit(VideoLikesError(failure.toString()));
      },
      (response) {
        AppLogger.navInfo('Like registrado con éxito: ${response.likeId}');
        emit(VideoLikeSuccess(response));
        // Actualizamos el estado para reflejar que el video ha sido dado like
        emit(VideoLikeStatus(isLiked: true, videoId: event.videoId));
      },
    );
  }

  Future<void> _onUnlikeVideo(
    UnlikeVideoEvent event,
    Emitter<VideoLikesState> emit,
  ) async {
    emit(const VideoLikesLoading());
    
    AppLogger.navInfo(
      'Quitando like al video ${event.videoId} por el cliente ${event.customerId}',
    );
    
    final params = LikeVideoParams(
      customerId: event.customerId,
      videoId: event.videoId,
    );
    
    final result = await unlikeVideo(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al quitar like: ${failure.toString()}');
        emit(VideoLikesError(failure.toString()));
      },
      (response) {
        AppLogger.navInfo('Like eliminado con éxito');
        emit(VideoUnlikeSuccess(response));
        // Actualizamos el estado para reflejar que el video ya no tiene like
        emit(VideoLikeStatus(isLiked: false, videoId: event.videoId));
      },
    );
  }

  Future<void> _onCheckVideoLikeStatus(
    CheckVideoLikeStatusEvent event,
    Emitter<VideoLikesState> emit,
  ) async {
    emit(const VideoLikesLoading());
    
    AppLogger.navInfo(
      'Verificando like para video ${event.videoId} del cliente ${event.customerId}',
    );
    
    final params = LikeVideoParams(
      customerId: event.customerId,
      videoId: event.videoId,
    );
    
    final result = await hasUserLikedVideo(params);
    
    result.fold(
      (failure) {
        AppLogger.navError('Error al verificar like: ${failure.toString()}');
        emit(VideoLikesError(failure.toString()));
      },
      (isLiked) {
        AppLogger.navInfo('Estado del like: $isLiked');
        emit(VideoLikeStatus(isLiked: isLiked, videoId: event.videoId));
      },
    );
  }
}
