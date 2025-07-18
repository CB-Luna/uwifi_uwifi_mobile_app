import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../customer/domain/entities/customer_details.dart';
import '../entities/referral.dart';
import '../repositories/invite_repository.dart';

/// Parámetros para el caso de uso GetUserReferral
class GetUserReferralParams extends Equatable {
  final CustomerDetails? customerDetails;

  const GetUserReferralParams({this.customerDetails});

  @override
  List<Object?> get props => [customerDetails];
}

/// Caso de uso para obtener la información del referido del usuario
class GetUserReferral implements UseCase<Referral, GetUserReferralParams> {
  final InviteRepository repository;

  GetUserReferral(this.repository);

  @override
  Future<Either<Failure, Referral>> call(GetUserReferralParams params) async {
    return await repository.getUserReferral(customerDetails: params.customerDetails);
  }
}
