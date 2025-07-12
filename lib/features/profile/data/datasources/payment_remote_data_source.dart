import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/credit_card_model.dart';

abstract class PaymentRemoteDataSource {
  Future<Either<Failure, List<CreditCardModel>>> getCreditCards(String customerId);
}
