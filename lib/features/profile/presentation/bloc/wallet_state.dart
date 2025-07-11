import 'package:equatable/equatable.dart';
import '../../domain/entities/affiliated_user.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<AffiliatedUser> affiliatedUsers;

  const WalletLoaded({required this.affiliatedUsers});

  @override
  List<Object?> get props => [affiliatedUsers];

  WalletLoaded copyWith({
    List<AffiliatedUser>? affiliatedUsers,
  }) {
    return WalletLoaded(
      affiliatedUsers: affiliatedUsers ?? this.affiliatedUsers,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}
