import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/customer_details_model.dart';

abstract class CustomerLocalDataSource {
  /// Gets the cached [CustomerDetailsModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<CustomerDetailsModel> getLastCustomerDetails();

  /// Caches the [CustomerDetailsModel] to be retrieved later when
  /// there's no internet connection.
  Future<void> cacheCustomerDetails(
    CustomerDetailsModel customerDetailsToCache,
  );
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final SharedPreferences sharedPreferences;

  CustomerLocalDataSourceImpl({required this.sharedPreferences});

  static const cachedCustomerDetailsKey = 'CACHED_CUSTOMER_DETAILS';

  @override
  Future<CustomerDetailsModel> getLastCustomerDetails() async {
    final jsonString = sharedPreferences.getString(cachedCustomerDetailsKey);
    if (jsonString != null) {
      AppLogger.navInfo('Recuperando detalles del cliente desde caché');
      return CustomerDetailsModel.fromJson(json.decode(jsonString));
    } else {
      AppLogger.navError('No se encontraron detalles del cliente en caché');
      throw CacheException();
    }
  }

  @override
  Future<void> cacheCustomerDetails(
    CustomerDetailsModel customerDetailsToCache,
  ) async {
    AppLogger.navInfo('Guardando detalles del cliente en caché');
    await sharedPreferences.setString(
      cachedCustomerDetailsKey,
      json.encode(customerDetailsToCache.toJson()),
    );
  }
}
