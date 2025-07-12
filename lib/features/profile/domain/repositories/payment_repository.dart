import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/credit_card.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<CreditCard>>> getCreditCards(String customerId);
}
