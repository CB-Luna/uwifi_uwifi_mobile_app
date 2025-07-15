import '../models/customer_bundle_model.dart';

abstract class CustomerBundleRemoteDataSource {
  /// Calls the customer_bundle RPC endpoint
  ///
  /// Throws a [ServerException] for all error codes
  Future<List<CustomerBundleModel>> getCustomerBundle(int customerId);
}
