import '../../domain/entities/affiliated_user.dart';

class AffiliatedUserModel extends AffiliatedUser {
  const AffiliatedUserModel({
    required super.customerId,
    required super.customerName,
    required super.isAffiliate,
  });

  factory AffiliatedUserModel.fromJson(Map<String, dynamic> json) {
    // Manejo seguro de los campos con valores predeterminados para evitar errores
    int customerId;
    try {
      // Intentar convertir a int si viene como string
      final rawId = json['customer_id'];
      if (rawId is int) {
        customerId = rawId;
      } else if (rawId is String) {
        customerId = int.tryParse(rawId) ?? 0;
      } else {
        customerId = 0;
      }
    } catch (e) {
      customerId = 0;
    }

    // Manejo seguro del nombre
    String customerName;
    try {
      final rawName = json['customer_name'];
      customerName = rawName?.toString() ?? 'Usuario';
    } catch (e) {
      customerName = 'Usuario';
    }

    // Manejo seguro del flag de afiliado
    bool isAffiliate;
    try {
      final rawIsAffiliate = json['is_affiliate'];
      if (rawIsAffiliate is bool) {
        isAffiliate = rawIsAffiliate;
      } else if (rawIsAffiliate is String) {
        isAffiliate = rawIsAffiliate.toLowerCase() == 'true';
      } else if (rawIsAffiliate is num) {
        isAffiliate = rawIsAffiliate != 0;
      } else {
        isAffiliate = false;
      }
    } catch (e) {
      isAffiliate = false;
    }

    return AffiliatedUserModel(
      customerId: customerId,
      customerName: customerName,
      isAffiliate: isAffiliate,
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
