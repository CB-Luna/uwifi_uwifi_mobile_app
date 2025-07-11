import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../models/billing_period_model.dart';
import 'billing_remote_data_source.dart';

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final SupabaseClient supabaseClient;

  BillingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<Either<Failure, BillingPeriodModel>> getCurrentBillingPeriod(
    String customerId,
  ) async {
    try {
      // Preparar el cuerpo de la solicitud
      final requestBody = {'customer_id': customerId};

      // Realizar la solicitud POST a la función RPC de Supabase
      final response = await supabaseClient.rpc(
        'get_current_billing_period',
        params: requestBody,
      );

      if (response == null) {
        return const Left(
          ServerFailure('Error al obtener el período de facturación'),
        );
      }

      final billingPeriodModel = BillingPeriodModel.fromJson(response);

      return Right(billingPeriodModel);
    } catch (e) {
      return Left(
        ServerFailure('Error al obtener el período de facturación: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> getCustomerBalance(String customerId) async {
    try {
      // Preparar el cuerpo de la solicitud
      final requestBody = {'customer_id_param': customerId};

      // Realizar la solicitud RPC a Supabase
      final response = await supabaseClient.rpc(
        'get_customer_balance',
        params: requestBody,
      );

      if (response == null) {
        return const Left(
          ServerFailure('Error al obtener el balance del cliente'),
        );
      }

      // Convertir el resultado a double
      final balance = (response as num).toDouble();
      
      return Right(balance);
    } catch (e) {
      return Left(
        ServerFailure('Error al obtener el balance del cliente: $e'),
      );
    }
  }
}
