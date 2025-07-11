import '../../domain/entities/affiliated_user.dart';

class AffiliatedUserModel extends AffiliatedUser {
  const AffiliatedUserModel({
    required super.customerId,
    required super.customerName,
    required super.isAffiliate,
  });

  factory AffiliatedUserModel.fromJson(Map<String, dynamic> json) {
    return AffiliatedUserModel(
      customerId: json['customer_id'] as int,
      customerName: json['customer_name'] as String,
      isAffiliate: json['is_affiliate'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'is_affiliate': isAffiliate,
    };
  }

  factory AffiliatedUserModel.fromEntity(AffiliatedUser user) {
    return AffiliatedUserModel(
      customerId: user.customerId,
      customerName: user.customerName,
      isAffiliate: user.isAffiliate,
    );
  }
}
