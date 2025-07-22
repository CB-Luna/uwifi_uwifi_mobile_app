import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/customer_details_model.dart';

abstract class CustomerRemoteDataSource {
  /// Calls the get_customer_details endpoint.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<CustomerDetailsModel> getCustomerDetails(int customerId);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CustomerDetailsModel> getCustomerDetails(int customerId) async {
    try {
      AppLogger.navInfo(
        'Getting customer details for customerId: $customerId',
      );

      // Prepare the request body
      final requestBody = {'customer_id': customerId};

      // Make the POST request to the RPC function
      final response = await supabaseClient.rpc(
        'get_customer_details',
        params: requestBody,
      );

      AppLogger.navInfo('Response received: $response');

      if (response == null) {
        AppLogger.navError(
          'Error getting customer details: null response',
        );
        throw ServerException('Error getting customer details');
      }

      // The response is already the list of results
      if (response is List) {
        // If the response is directly a list
        final List<dynamic> responseData = response;
        
        if (responseData.isEmpty) {
          throw ServerException('No details found for the customer');
        }
        
        // Convert the response to a model
        return CustomerDetailsModel.fromJson(responseData[0]);
      } else {
        // If the response is a map or other type
        AppLogger.navInfo('Response type: ${response.runtimeType}');
        
        // Try to convert the response directly to a model
        try {
          if (response is Map<String, dynamic>) {
            return CustomerDetailsModel.fromJson(response);
          } else {
            throw ServerException('Unexpected response format');
          }
        } catch (e) {
          AppLogger.navError('Error parsing the response: $e');
          throw ServerException('Error parsing the response: $e');
        }
      }
    } catch (e) {
      AppLogger.navError('Error in getCustomerDetails: $e');
      throw ServerException(e.toString());
    }
  }
}
