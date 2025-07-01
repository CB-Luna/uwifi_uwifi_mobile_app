import '../models/referral_model.dart';

/// Data source abstracto para manejar invitaciones remotas
abstract class InviteRemoteDataSource {
  /// Obtiene la información del referido del usuario actual
  Future<ReferralModel> getUserReferral();
  
  /// Genera un nuevo código de referido para el usuario
  Future<ReferralModel> generateReferralCode();
  
  /// Obtiene las estadísticas de referidos del usuario
  Future<Map<String, dynamic>> getReferralStats();
}
