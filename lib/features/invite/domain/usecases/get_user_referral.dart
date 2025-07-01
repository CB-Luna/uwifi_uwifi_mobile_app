import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/referral.dart';
import '../repositories/invite_repository.dart';

/// Caso de uso para obtener la información del referido del usuario
class GetUserReferral implements UseCase<Referral, NoParams> {
  final InviteRepository repository;

  GetUserReferral(this.repository);

  @override
  Future<Either<Failure, Referral>> call(NoParams params) async {
    return await repository.getUserReferral();
  }
}
