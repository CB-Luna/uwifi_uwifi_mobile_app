import 'package:equatable/equatable.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';

/// Modelo para la respuesta de las operaciones de like/unlike
class LikeResponseModel extends Equatable {
  final bool success;
  final String message;
  final int? likeId;

  const LikeResponseModel({
    required this.success,
    required this.message,
    this.likeId,
  });

  /// Convierte un JSON a un modelo LikeResponseModel
  factory LikeResponseModel.fromJson(Map<String, dynamic> json) {
    return LikeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? 'No message provided',
      likeId: json['customer_liked_id'],
    );
  }

  /// Convierte el modelo a una entidad LikeResponse
  LikeResponse toEntity() {
    return LikeResponse(
      success: success,
      message: message,
      likeId: likeId,
    );
  }

  @override
  List<Object?> get props => [success, message, likeId];
}
