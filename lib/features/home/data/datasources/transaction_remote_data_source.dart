import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<Either<Failure, List<TransactionModel>>> getTransactionHistory(String customerId);
}
