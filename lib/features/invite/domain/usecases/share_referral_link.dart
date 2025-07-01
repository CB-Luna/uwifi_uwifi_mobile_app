import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/invite_repository.dart';

/// Caso de uso para compartir el enlace de referido
class ShareReferralLink implements UseCase<bool, ShareReferralLinkParams> {
  final InviteRepository repository;

  ShareReferralLink(this.repository);

  @override
  Future<Either<Failure, bool>> call(ShareReferralLinkParams params) async {
    return await repository.shareReferralLink(params.referralLink);
  }
}

class ShareReferralLinkParams extends Equatable {
  final String referralLink;

  const ShareReferralLinkParams({required this.referralLink});

  @override
  List<Object?> get props => [referralLink];
}
