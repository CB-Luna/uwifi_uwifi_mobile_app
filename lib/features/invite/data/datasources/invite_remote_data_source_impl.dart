import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/referral_model.dart';
import 'invite_remote_data_source.dart';
import 'invite_demo_data.dart';

/// Implementación del data source remoto para invitaciones
class InviteRemoteDataSourceImpl implements InviteRemoteDataSource {
  final SupabaseClient supabaseClient;

  InviteRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ReferralModel> getUserReferral() async {
    debugPrint('📱 InviteRemoteDataSource: Iniciando getUserReferral (MODO DEMO)...');
    
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    
    try {
      final user = supabaseClient.auth.currentUser;
      debugPrint('👤 InviteRemoteDataSource: Usuario actual: ${user?.id ?? "guest"}');
      
      // Usar datos demo en lugar de consultar Supabase
      debugPrint('🎭 InviteRemoteDataSource: Generando datos demo...');
      final demoReferral = InviteDemoData.getUserReferralDemo(userId: user?.id);
      
      debugPrint('✅ InviteRemoteDataSource: Datos demo generados exitosamente');
      debugPrint('📊 Código de referido: ${demoReferral.referralCode}');
      debugPrint('💰 Total referidos: ${demoReferral.totalReferrals}');
      debugPrint('💵 Ganancias totales: \$${demoReferral.totalEarnings.toStringAsFixed(2)}');
      
      return demoReferral;
    } catch (e) {
      debugPrint('💥 InviteRemoteDataSource: Error al generar datos demo: $e');
      throw ServerException();
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
      final referralLink = 'https://u-wifi.virtualus.cbluna-dev.com/invite/$referralCode';

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
