import '../../../customer/domain/entities/customer_details.dart';
import '../models/referral_model.dart';

/// Data source abstracto para manejar invitaciones remotas
abstract class InviteRemoteDataSource {
  /// Obtiene la información del referido del usuario actual
  /// [customerDetails] Detalles del cliente para usar el sharedLinkId como código de referido
  Future<ReferralModel> getUserReferral({CustomerDetails? customerDetails});
  
  /// Genera un nuevo código de referido para el usuario
  Future<ReferralModel> generateReferralCode();
  
  /// Obtiene las estadísticas de referidos del usuario
  Future<Map<String, dynamic>> getReferralStats();
}
