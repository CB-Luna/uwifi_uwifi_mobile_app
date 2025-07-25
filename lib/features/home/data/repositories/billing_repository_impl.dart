import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/billing_period.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_remote_data_source.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BillingRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BillingPeriod>> getCurrentBillingPeriod(
    String customerId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteBillingPeriod = await remoteDataSource
            .getCurrentBillingPeriod(customerId);
        return remoteBillingPeriod.fold(
          (failure) => Left(failure),
          (billingPeriodModel) => Right(billingPeriodModel),
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, double>> getCustomerBalance(String customerId) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.getCustomerBalance(customerId);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
  
  @override
  Future<Either<Failure, bool>> updateAutomaticCharge({
    required String customerId,
    required bool value,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.updateAutomaticCharge(
          customerId: customerId,
          value: value,
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> createManualBilling({
    required int customerId,
    required String billingDate,
    required double discount,
    required bool autoPayment,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        return await remoteDataSource.createManualBilling(
          customerId: customerId,
          billingDate: billingDate,
          discount: discount,
          autoPayment: autoPayment,
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }
}
