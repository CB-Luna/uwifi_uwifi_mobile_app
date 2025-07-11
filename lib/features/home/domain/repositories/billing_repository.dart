import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/billing_period.dart';

abstract class BillingRepository {
  /// Obtiene el período de facturación actual para un cliente
  /// 
  /// Retorna un [BillingPeriod] si la solicitud es exitosa
  /// Retorna un [Failure] si hay un error
  Future<Either<Failure, BillingPeriod>> getCurrentBillingPeriod(String customerId);
  
  /// Obtiene el balance (monto a pagar) para un cliente
  Future<Either<Failure, double>> getCustomerBalance(String customerId);
}
