import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/credit_card.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<CreditCard>>> getCreditCards(String customerId);
  
  Future<Either<Failure, bool>> setDefaultCard({
    required String customerId,
    required String cardId,
  });
  
  Future<Either<Failure, bool>> deleteCreditCard({
    required String customerId,
    required String cardId,
  });
}
