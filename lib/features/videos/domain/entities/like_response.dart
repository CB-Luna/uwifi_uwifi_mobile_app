import 'package:equatable/equatable.dart';

/// Entidad que representa la respuesta de una operación de like/unlike
class LikeResponse extends Equatable {
  final bool success;
  final String message;
  final int? likeId;

  const LikeResponse({
    required this.success,
    required this.message,
    this.likeId,
  });

  @override
  List<Object?> get props => [success, message, likeId];
}
