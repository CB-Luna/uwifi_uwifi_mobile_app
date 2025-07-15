import 'package:equatable/equatable.dart';
import '../../domain/entities/affiliated_user.dart';
import '../../domain/entities/customer_points.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {
  final List<AffiliatedUser>? affiliatedUsers;
  final CustomerPoints? customerPoints;
  
  const WalletLoading({
    this.affiliatedUsers,
    this.customerPoints,
  });
  
  factory WalletLoading.fromLoaded(WalletLoaded loaded) {
    return WalletLoading(
      affiliatedUsers: loaded.affiliatedUsers,
      customerPoints: loaded.customerPoints,
    );
  }
  
  @override
  List<Object?> get props => [affiliatedUsers, customerPoints];
}

class WalletLoaded extends WalletState {
  final List<AffiliatedUser> affiliatedUsers;
  final CustomerPoints? customerPoints;

  const WalletLoaded({
    required this.affiliatedUsers,
    this.customerPoints,
  });

  @override
  List<Object?> get props => [affiliatedUsers, customerPoints];

  WalletLoaded copyWith({
    List<AffiliatedUser>? affiliatedUsers,
    CustomerPoints? customerPoints,
  }) {
    return WalletLoaded(
      affiliatedUsers: affiliatedUsers ?? this.affiliatedUsers,
      customerPoints: customerPoints ?? this.customerPoints,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
