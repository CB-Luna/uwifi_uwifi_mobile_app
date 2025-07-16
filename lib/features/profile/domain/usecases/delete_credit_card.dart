import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class DeleteCreditCard implements UseCase<bool, DeleteCreditCardParams> {
  final PaymentRepository repository;

  DeleteCreditCard(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteCreditCardParams params) async {
    return await repository.deleteCreditCard(
      customerId: params.customerId,
      cardId: params.cardId,
    );
  }
}

class DeleteCreditCardParams {
  final String customerId;
  final String cardId;

  DeleteCreditCardParams({
    required this.customerId,
    required this.cardId,
  });
}
