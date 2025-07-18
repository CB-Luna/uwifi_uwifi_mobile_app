import 'package:equatable/equatable.dart';

/// Entidad que representa un referido
class Referral extends Equatable {
  final String id;
  final String referralCode;
  final String referralLink;
  final int userId;
  final int totalReferrals;
  final double totalEarnings;
  final DateTime createdAt;
  final bool isActive;

  const Referral({
    required this.id,
    required this.referralCode,
    required this.referralLink,
    required this.userId,
    required this.totalReferrals,
    required this.totalEarnings,
    required this.createdAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    referralCode,
    referralLink,
    userId,
    totalReferrals,
    totalEarnings,
    createdAt,
    isActive,
  ];
}
