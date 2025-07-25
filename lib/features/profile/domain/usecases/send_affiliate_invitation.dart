import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/affiliate_repository.dart';

class SendAffiliateInvitation implements UseCase<bool, SendAffiliateInvitationParams> {
  final AffiliateRepository repository;

  SendAffiliateInvitation(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendAffiliateInvitationParams params) {
    return repository.sendAffiliateInvitation(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      customerId: params.customerId,
    );
  }
}

class SendAffiliateInvitationParams {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int customerId;

  SendAffiliateInvitationParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.customerId,
  });
}
