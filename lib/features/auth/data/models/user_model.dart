import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    super.name,
    super.profileImageUrl,
    super.customerId,
    super.customerAfiliateId,
    super.sharedLinkId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customerId: json['customer_id'] != null ? json['customer_id'] as int : null,
      customerAfiliateId: json['customer_afiliate_id'] != null ? json['customer_afiliate_id'] as int : null,
      sharedLinkId: json['shared_link_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer_id': customerId,
      'customer_afiliate_id': customerAfiliateId,
      'shared_link_id': sharedLinkId,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
