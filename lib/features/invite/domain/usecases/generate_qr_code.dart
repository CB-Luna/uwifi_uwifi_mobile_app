import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invite_repository.dart';

/// Caso de uso para generar código QR del enlace de referido
class GenerateQRCode implements UseCase<String, GenerateQRCodeParams> {
  final InviteRepository repository;

  GenerateQRCode(this.repository);

  @override
  Future<Either<Failure, String>> call(GenerateQRCodeParams params) async {
    return await repository.generateQRCode(params.referralLink);
  }
}

class GenerateQRCodeParams extends Equatable {
  final String referralLink;

  const GenerateQRCodeParams({required this.referralLink});

  @override
  List<Object?> get props => [referralLink];
}
