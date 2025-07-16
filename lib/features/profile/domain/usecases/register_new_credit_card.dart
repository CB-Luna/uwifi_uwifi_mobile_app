import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/payment_repository.dart';

class RegisterNewCreditCard implements UseCase<bool, RegisterNewCreditCardParams> {
  final PaymentRepository repository;

  RegisterNewCreditCard(this.repository);

  @override
  Future<Either<Failure, bool>> call(RegisterNewCreditCardParams params) async {
    return await repository.registerNewCreditCard(
      customerId: params.customerId,
      cardNumber: params.cardNumber,
      expMonth: params.expMonth,
      expYear: params.expYear,
      cvv: params.cvv,
      cardHolder: params.cardHolder,
    );
  }
}

class RegisterNewCreditCardParams {
  final String customerId;
  final String cardNumber;
  final String expMonth;
  final String expYear;
  final String cvv;
  final String cardHolder;

  RegisterNewCreditCardParams({
    required this.customerId,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
    required this.cardHolder,
  });
}
