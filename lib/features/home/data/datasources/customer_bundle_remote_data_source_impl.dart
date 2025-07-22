import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/customer_bundle_model.dart';
import 'customer_bundle_remote_data_source.dart';

class CustomerBundleRemoteDataSourceImpl implements CustomerBundleRemoteDataSource {
  final SupabaseClient supabaseClient;

  CustomerBundleRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CustomerBundleModel>> getCustomerBundle(int customerId) async {
    try {
      AppLogger.navInfo(
        'Requesting customer bundle: $customerId',
      );

      final response = await supabaseClient.rpc(
        'customer_bundle',
        params: {'customer_id': customerId},
      );

      // Verify if the response is valid
      if (response == null) {
        AppLogger.navError('Error: null response when getting customer bundle');
        throw ServerException('Error: null response when getting customer bundle');
      }

      AppLogger.navInfo('Customer bundle response: ${jsonEncode(response)}');

      // Convert the response to a list of models
      if (response is List) {
        return response
            .map((item) => CustomerBundleModel.fromJson(item))
            .toList();
      } else {
        AppLogger.navError('Error: unexpected response format');
        throw ServerException('Error: unexpected response format');
      }
    } catch (e) {
      AppLogger.navError('Error getting customer bundle: $e');
      throw ServerException(e.toString());
    }
  }
}
