import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id; // auth_id (UUID)
  final String email;
  final String? name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? customerId; // customer_id (bigint)
  final int? customerAfiliateId; // customer_afiliate_id (bigint)
  final String? sharedLinkId; // shared_link_id (text)

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.profileImageUrl,
    this.customerId,
    this.customerAfiliateId,
    this.sharedLinkId,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profileImageUrl,
    createdAt,
    updatedAt,
    customerId,
    customerAfiliateId,
    sharedLinkId,
  ];
}
