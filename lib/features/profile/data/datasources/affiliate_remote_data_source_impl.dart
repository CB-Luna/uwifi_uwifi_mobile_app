import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import 'affiliate_remote_data_source.dart';

class AffiliateRemoteDataSourceImpl implements AffiliateRemoteDataSource {
  final http.Client client;

  AffiliateRemoteDataSourceImpl({required this.client});

  @override
  Future<Either<Failure, bool>> sendAffiliateInvitation({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required int customerId,
  }) async {
    try {
      AppLogger.info('Sending affiliate invitation for email: $email');

      final response = await client.post(
        Uri.parse(ApiEndpoints.sendAffiliateInvitation),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone': phone,
          'customer_id': customerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info('Affiliate invitation sent successfully');
        return const Right(true);
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        AppLogger.error('Error sending affiliate invitation: $errorMessage');
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      AppLogger.error('Exception sending affiliate invitation: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
