import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/credit_card.dart';
import '../repositories/payment_repository.dart';

class GetCreditCards implements UseCase<List<CreditCard>, String> {
  final PaymentRepository repository;

  GetCreditCards(this.repository);

  @override
  Future<Either<Failure, List<CreditCard>>> call(String customerId) async {
    return repository.getCreditCards(customerId);
  }
}
