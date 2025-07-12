import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionHistory {
  final TransactionRepository repository;

  GetTransactionHistory(this.repository);

  Future<Either<Failure, List<Transaction>>> call(String customerId) async {
    return await repository.getTransactionHistory(customerId);
  }
}
