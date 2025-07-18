import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uwifiapp/core/constants/api_endpoints.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../injection_container.dart';
import '../../../customer/domain/entities/customer_details.dart';
import '../../../customer/presentation/bloc/customer_details_bloc.dart';
import '../models/referral_model.dart';
import 'invite_demo_data.dart';
import 'invite_remote_data_source.dart';

/// Implementación del data source remoto para invitaciones
class InviteRemoteDataSourceImpl implements InviteRemoteDataSource {
  final SupabaseClient supabaseClient;
  final CustomerDetails? customerDetails;

  InviteRemoteDataSourceImpl({
    required this.supabaseClient,
    this.customerDetails,
  });

  @override
  Future<ReferralModel> getUserReferral({
    CustomerDetails? customerDetails,
  }) async {
    AppLogger.navInfo(
      'InviteRemoteDataSource: Iniciando getUserReferral (MODO DEMO)...',
    );

    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final user = supabaseClient.auth.currentUser;
      AppLogger.navInfo(
        'InviteRemoteDataSource: Usuario actual: ${user?.id ?? "guest"}',
      );

      // Obtener el sharedLinkId desde customerDetails si está disponible
      String? sharedLinkId;
      int? customerId;

      // Primero intentamos usar el customerDetails pasado como parámetro
      CustomerDetails? currentCustomerDetails = customerDetails;

      // Si no está disponible como parámetro, intentamos usar el inyectado
      if (currentCustomerDetails == null) {
        currentCustomerDetails = this.customerDetails;
        if (currentCustomerDetails != null) {
          AppLogger.navInfo(
            'InviteRemoteDataSource: Usando CustomerDetails inyectado',
          );
        }
      } else {
        AppLogger.navInfo(
          'InviteRemoteDataSource: Usando CustomerDetails pasado como parámetro',
        );
      }

      // Si aún no está disponible, intentamos obtenerlo del bloc
      if (currentCustomerDetails == null) {
        try {
          final customerDetailsBloc = getIt<CustomerDetailsBloc>();
          final state = customerDetailsBloc.state;
          if (state is CustomerDetailsLoaded) {
            currentCustomerDetails = state.customerDetails;
            AppLogger.navInfo(
              'InviteRemoteDataSource: CustomerDetails obtenido del bloc',
            );
          }
        } catch (e) {
          AppLogger.navError(
            'InviteRemoteDataSource: Error al obtener CustomerDetailsBloc: $e',
          );
        }
      }

      if (currentCustomerDetails != null) {
        sharedLinkId = currentCustomerDetails.sharedLinkId;
        customerId = currentCustomerDetails.customerId;
        AppLogger.navInfo(
          'InviteRemoteDataSource: Usando sharedLinkId: $sharedLinkId',
        );
      } else {
        AppLogger.navInfo(
          'InviteRemoteDataSource: customerDetails no disponible, usando código generado',
        );
      }

      // Usar datos demo en lugar de consultar Supabase
      AppLogger.navInfo('InviteRemoteDataSource: Generando datos demo...');
      final demoReferral = InviteDemoData.getUserReferralDemo(
        userId: user?.id,
        customerId: customerId,
        sharedLinkId: sharedLinkId,
      );

      AppLogger.navInfo(
        'InviteRemoteDataSource: Datos demo generados exitosamente',
      );
      AppLogger.navInfo('Código de referido: ${demoReferral.referralCode}');
      AppLogger.navInfo('Total referidos: ${demoReferral.totalReferrals}');
      AppLogger.navInfo(
        'Ganancias totales: \$${demoReferral.totalEarnings.toStringAsFixed(2)}',
      );

      return demoReferral;
    } catch (e) {
      AppLogger.navError(
        'InviteRemoteDataSource: Error al generar datos demo: $e',
      );
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ReferralModel> generateReferralCode() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw ServerException();
      }

      // Generar código único
      final referralCode = _generateUniqueCode(user.id);
      final referralLink = '${ApiEndpoints.inviteBaseUrl}/$referralCode';

      final referralData = {
        'user_id': user.id,
        'referral_code': referralCode,
        'referral_link': referralLink,
        'total_referrals': 0,
        'total_earnings': 0.0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await supabaseClient
          .from('referrals')
          .upsert(referralData)
          .select()
          .single();

      return ReferralModel.fromJson(response);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw ServerException();
      }

      final response = await supabaseClient
          .from('referrals')
          .select('total_referrals, total_earnings')
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      throw ServerException();
    }
  }

  /// Genera un código único basado en el ID del usuario
  String _generateUniqueCode(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final userHash = userId.hashCode.abs();
    return '${userHash.toString().substring(0, 4)}$timestamp'.substring(0, 12);
  }
}
