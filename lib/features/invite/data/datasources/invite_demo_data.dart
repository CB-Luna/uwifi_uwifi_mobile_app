import 'package:uwifiapp/core/constants/api_endpoints.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/referral_model.dart';

/// Servicio de datos demo para simular la API de referidos
class InviteDemoData {
  /// Simula la obtención de datos de referido del usuario
  /// Si se proporciona sharedLinkId, se usará como código de referido
  static ReferralModel getUserReferralDemo({
    String? userId,
    int? customerId,
    String? sharedLinkId,
  }) {
    final now = DateTime.now();

    // Usar sharedLinkId si está disponible, de lo contrario generar uno
    final userCode = sharedLinkId != null && sharedLinkId.isNotEmpty
        ? sharedLinkId
        : userId != null
        ? 'USER${userId.substring(0, 8).toUpperCase()}'
        : 'DEMO${now.millisecondsSinceEpoch.toString().substring(8)}';

    AppLogger.navInfo(
      'Generando código de referido: $userCode (sharedLinkId: $sharedLinkId)',
    );

    return ReferralModel(
      id: userId ?? 'demo-user-id',
      referralCode: userCode,
      referralLink: '${ApiEndpoints.inviteBaseUrl}/$userCode',
      userId: customerId ?? 0,
      totalReferrals: _getRandomReferrals(),
      totalEarnings: _getRandomEarnings(),
      createdAt: now.subtract(Duration(days: _getRandomDays())),
      isActive: true,
    );
  }

  /// Simula diferentes usuarios con datos variados
  static List<ReferralModel> getAllDemoReferrals() {
    return [
      ReferralModel(
        id: 'demo-1',
        referralCode: 'DEMO001',
        referralLink: '${ApiEndpoints.inviteBaseUrl}/DEMO001',
        userId: 1,
        totalReferrals: 5,
        totalEarnings: 25.50,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isActive: true,
      ),
      ReferralModel(
        id: 'demo-2',
        referralCode: 'DEMO002',
        referralLink: '${ApiEndpoints.inviteBaseUrl}/DEMO002',
        userId: 2,
        totalReferrals: 12,
        totalEarnings: 60.00,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
      ),
      ReferralModel(
        id: 'demo-3',
        referralCode: 'DEMO003',
        referralLink: '${ApiEndpoints.inviteBaseUrl}/DEMO003',
        userId: 3,
        totalReferrals: 0,
        totalEarnings: 0.0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
      ),
    ];
  }

  /// Genera un número aleatorio de referidos (0-20)
  static int _getRandomReferrals() {
    final random = DateTime.now().millisecondsSinceEpoch % 21;
    return random;
  }

  /// Genera ganancias aleatorias basadas en referidos
  static double _getRandomEarnings() {
    final referrals = _getRandomReferrals();
    final baseEarning = 5.0; // $5 por referido
    final bonus =
        (DateTime.now().millisecondsSinceEpoch % 100) / 100; // Bonus aleatorio
    return (referrals * baseEarning) + bonus;
  }

  /// Genera días aleatorios para la fecha de creación (1-90 días)
  static int _getRandomDays() {
    return (DateTime.now().millisecondsSinceEpoch % 90) + 1;
  }

  /// Simula estadísticas adicionales para el dashboard
  static Map<String, dynamic> getReferralStats({String? userId}) {
    final referrals = _getRandomReferrals();
    return {
      'total_referrals': referrals,
      'total_earnings': _getRandomEarnings(),
      'pending_earnings': _getRandomEarnings() * 0.3,
      'this_month_referrals': (referrals * 0.4).round(),
      'conversion_rate':
          0.15 + (DateTime.now().millisecondsSinceEpoch % 35) / 100,
      'top_referrer_rank': (DateTime.now().millisecondsSinceEpoch % 100) + 1,
    };
  }

  /// Simula el historial de referidos
  static List<Map<String, dynamic>> getReferralHistory({String? userId}) {
    final history = <Map<String, dynamic>>[];
    final referrals = _getRandomReferrals();

    for (int i = 0; i < referrals; i++) {
      final daysAgo = (DateTime.now().millisecondsSinceEpoch % 30) + 1;
      history.add({
        'id': 'ref-$i',
        'referred_user_name': 'Usuario ${i + 1}',
        'referred_date': DateTime.now()
            .subtract(Duration(days: daysAgo))
            .toIso8601String(),
        'status': i % 4 == 0 ? 'pending' : 'completed',
        'earnings': 5.0,
      });
    }

    return history;
  }
}
