import '../../domain/entities/referral.dart';

/// Modelo de datos para Referral
class ReferralModel extends Referral {
  const ReferralModel({
    required super.id,
    required super.referralCode,
    required super.referralLink,
    required super.userId,
    required super.totalReferrals,
    required super.totalEarnings,
    required super.createdAt,
    required super.isActive,
  });

  /// Crea un ReferralModel desde JSON
  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] ?? '',
      referralCode: json['referral_code'] ?? '',
      referralLink: json['referral_link'] ?? '',
      userId: json['user_id'] ?? 0,
      totalReferrals: json['total_referrals'] ?? 0,
      totalEarnings: (json['total_earnings'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isActive: json['is_active'] ?? true,
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referral_code': referralCode,
      'referral_link': referralLink,
      'user_id': userId,
      'total_referrals': totalReferrals,
      'total_earnings': totalEarnings,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Crea una copia del modelo con campos actualizados
  ReferralModel copyWith({
    String? id,
    String? referralCode,
    String? referralLink,
    int? userId,
    int? totalReferrals,
    double? totalEarnings,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referralCode: referralCode ?? this.referralCode,
      referralLink: referralLink ?? this.referralLink,
      userId: userId ?? this.userId,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
