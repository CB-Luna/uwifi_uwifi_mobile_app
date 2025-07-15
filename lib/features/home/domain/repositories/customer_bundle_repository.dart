import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/customer_bundle.dart';

abstract class CustomerBundleRepository {
  /// Gets the customer bundle for a specific customer
  ///
  /// Returns [List<CustomerBundle>] if successful, [Failure] otherwise
  Future<Either<Failure, List<CustomerBundle>>> getCustomerBundle(int customerId);
}
