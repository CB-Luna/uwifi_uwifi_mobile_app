import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.name,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profileImageUrl,
    createdAt,
    updatedAt,
  ];
}
