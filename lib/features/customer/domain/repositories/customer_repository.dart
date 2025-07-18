import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/customer_details.dart';

abstract class CustomerRepository {
  Future<Either<Failure, CustomerDetails>> getCustomerDetails(int customerId);
}
