import '../../domain/entities/credit_card.dart';

class CreditCardModel extends CreditCard {
  const CreditCardModel({
    required super.id,
    required super.cardHolder,
    required super.createdAt,
    required super.expirationMonth,
    required super.expirationYear,
    required super.token,
    required super.customerFk,
    required super.isActive,
    required super.isDefault,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) {
    return CreditCardModel(
      id: json['credit_card_id'] as int,
      cardHolder: json['card_holder'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expirationMonth: json['exp_month'] as String,
      expirationYear: json['exp_year'] as String,
      token: json['token'] as String,
      customerFk: json['customer_fk'] as int,
      isActive: json['is_active'] as bool,
      isDefault: json['is_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'credit_card_id': id,
      'card_holder': cardHolder,
      'created_at': createdAt,
      'exp_month': expirationMonth,
      'exp_year': expirationYear,
      'token': token,
      'customer_fk': customerFk,
      'is_active': isActive,
      'is_default': isDefault,
    };
  }

  factory CreditCardModel.fromEntity(CreditCard card) {
    return CreditCardModel(
      id: card.id,
      cardHolder: card.cardHolder,
      createdAt: card.createdAt,
      expirationMonth: card.expirationMonth,
      expirationYear: card.expirationYear,
      token: card.token,
      customerFk: card.customerFk,
      isActive: card.isActive,
      isDefault: card.isDefault,
    );
  }
}
