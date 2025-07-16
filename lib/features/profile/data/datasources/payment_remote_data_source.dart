import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/credit_card_model.dart';

abstract class PaymentRemoteDataSource {
  Future<Either<Failure, List<CreditCardModel>>> getCreditCards(
    String customerId,
  );

  Future<Either<Failure, bool>> setDefaultCard({
    required String customerId,
    required String cardId,
  });

  Future<Either<Failure, bool>> deleteCreditCard({
    required String customerId,
    required String cardId,
  });
  
  Future<Either<Failure, bool>> registerNewCreditCard({
    required String customerId,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvv,
    required String cardHolder,
  });
}
