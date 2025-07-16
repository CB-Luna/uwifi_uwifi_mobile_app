import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class SetDefaultCard implements UseCase<bool, SetDefaultCardParams> {
  final PaymentRepository repository;

  SetDefaultCard(this.repository);

  @override
  Future<Either<Failure, bool>> call(SetDefaultCardParams params) async {
    return await repository.setDefaultCard(
      customerId: params.customerId,
      cardId: params.cardId,
    );
  }
}

class SetDefaultCardParams {
  final String customerId;
  final String cardId;

  SetDefaultCardParams({
    required this.customerId,
    required this.cardId,
  });
}
