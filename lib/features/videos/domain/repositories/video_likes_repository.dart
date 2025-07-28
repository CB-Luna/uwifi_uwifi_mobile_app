import 'package:dartz/dartz.dart';
import 'package:uwifiapp/core/errors/failures.dart';
import 'package:uwifiapp/features/videos/domain/entities/like_response.dart';

/// Repositorio para gestionar los likes de videos
abstract class VideoLikesRepository {
  /// Registra un like de un usuario para un video específico
  ///
  /// [customerId] ID del cliente que da like
  /// [videoId] ID del video (media_file_id) al que se da like
  /// 
  /// Retorna un [LikeResponse] con el resultado de la operación o un [Failure]
  Future<Either<Failure, LikeResponse>> likeVideo(int customerId, String videoId);
  
  /// Elimina un like de un usuario para un video específico
  ///
  /// [customerId] ID del cliente que elimina el like
  /// [videoId] ID del video (media_file_id) del que se elimina el like
  /// 
  /// Retorna un [LikeResponse] con el resultado de la operación o un [Failure]
  Future<Either<Failure, LikeResponse>> unlikeVideo(int customerId, String videoId);
  
  /// Verifica si un usuario ha dado like a un video específico
  ///
  /// [customerId] ID del cliente a verificar
  /// [videoId] ID del video (media_file_id) a verificar
  /// 
  /// Retorna true si el usuario ha dado like al video, false en caso contrario o un [Failure]
  Future<Either<Failure, bool>> hasUserLikedVideo(int customerId, String videoId);
}
