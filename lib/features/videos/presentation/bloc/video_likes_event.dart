import 'package:equatable/equatable.dart';

/// Eventos para el VideoLikesBloc
abstract class VideoLikesEvent extends Equatable {
  const VideoLikesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para dar like a un video
class LikeVideoEvent extends VideoLikesEvent {
  final int customerId;
  final String videoId;

  const LikeVideoEvent({
    required this.customerId,
    required this.videoId,
  });

  @override
  List<Object?> get props => [customerId, videoId];
}

/// Evento para quitar like a un video
class UnlikeVideoEvent extends VideoLikesEvent {
  final int customerId;
  final String videoId;

  const UnlikeVideoEvent({
    required this.customerId,
    required this.videoId,
  });

  @override
  List<Object?> get props => [customerId, videoId];
}

/// Evento para verificar si un usuario ha dado like a un video
class CheckVideoLikeStatusEvent extends VideoLikesEvent {
  final int customerId;
  final String videoId;

  const CheckVideoLikeStatusEvent({
    required this.customerId,
    required this.videoId,
  });

  @override
  List<Object?> get props => [customerId, videoId];
}
