import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/media_visualization.dart';
import '../repositories/media_visualization_repository.dart';

/// Caso de uso para registrar una visualización de video
class RegisterMediaVisualization implements UseCase<bool, RegisterMediaVisualizationParams> {
  final MediaVisualizationRepository repository;

  RegisterMediaVisualization(this.repository);

  @override
  Future<Either<Failure, bool>> call(RegisterMediaVisualizationParams params) async {
    return await repository.registerMediaVisualization(
      MediaVisualization(
        mediaFileId: params.mediaFileId,
        customerId: params.customerId,
        pointsEarned: params.pointsEarned,
        customerAfiliateId: params.customerAfiliateId,
      ),
    );
  }
}

/// Parámetros para el caso de uso RegisterMediaVisualization
class RegisterMediaVisualizationParams extends Equatable {
  final String mediaFileId;
  final int customerId;
  final int pointsEarned;
  final int customerAfiliateId;

  const RegisterMediaVisualizationParams({
    required this.mediaFileId,
    required this.customerId,
    required this.pointsEarned,
    required this.customerAfiliateId,
  });

  @override
  List<Object?> get props => [mediaFileId, customerId, pointsEarned, customerAfiliateId];
}
