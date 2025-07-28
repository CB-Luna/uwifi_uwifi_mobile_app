import 'package:equatable/equatable.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';

/// Estados para el VideoLikesBloc
abstract class VideoLikesState extends Equatable {
  const VideoLikesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class VideoLikesInitial extends VideoLikesState {
  const VideoLikesInitial();
}

/// Estado de carga
class VideoLikesLoading extends VideoLikesState {
  const VideoLikesLoading();
}

/// Estado de éxito al dar like
class VideoLikeSuccess extends VideoLikesState {
  final LikeResponse response;

  const VideoLikeSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// Estado de éxito al quitar like
class VideoUnlikeSuccess extends VideoLikesState {
  final LikeResponse response;

  const VideoUnlikeSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// Estado de error
class VideoLikesError extends VideoLikesState {
  final String message;

  const VideoLikesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado que indica si un video ha sido dado like por el usuario
class VideoLikeStatus extends VideoLikesState {
  final bool isLiked;
  final String videoId;

  const VideoLikeStatus({
    required this.isLiked,
    required this.videoId,
  });

  @override
  List<Object?> get props => [isLiked, videoId];
}
