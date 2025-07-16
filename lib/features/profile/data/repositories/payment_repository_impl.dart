import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/credit_card.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CreditCard>>> getCreditCards(
    String customerId,
  ) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.getCreditCards(customerId);
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setDefaultCard({
    required String customerId,
    required String cardId,
  }) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.setDefaultCard(
        customerId: customerId,
        cardId: cardId,
      );
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCreditCard({
    required String customerId,
    required String cardId,
  }) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.deleteCreditCard(
        customerId: customerId,
        cardId: cardId,
      );
    } else {
      return const Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, bool>> registerNewCreditCard({
    required String customerId,
    required String cardNumber,
    required String expMonth,
    required String expYear,
    required String cvv,
    required String cardHolder,
  }) async {
    if (await networkInfo.isConnected) {
      return remoteDataSource.registerNewCreditCard(
        customerId: customerId,
        cardNumber: cardNumber,
        expMonth: expMonth,
        expYear: expYear,
        cvv: cvv,
        cardHolder: cardHolder,
      );
    } else {
      return const Left(NetworkFailure());
    }
  }
}
