import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/billing_period_model.dart';

abstract class BillingRemoteDataSource {
  /// Obtiene el período de facturación actual para un cliente
  /// 
  /// Retorna un [BillingPeriodModel] si la solicitud es exitosa
  /// Lanza una [ServerException] si hay un error en el servidor
  Future<Either<Failure, BillingPeriodModel>> getCurrentBillingPeriod(String customerId);
  
  /// Obtiene el balance (monto a pagar) para un cliente
  Future<Either<Failure, double>> getCustomerBalance(String customerId);
}
