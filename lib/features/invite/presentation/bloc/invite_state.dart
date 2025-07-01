import 'package:equatable/equatable.dart';
import '../../domain/entities/referral.dart';

/// Estados del BLoC de invitaciones
abstract class InviteState extends Equatable {
  const InviteState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class InviteInitial extends InviteState {
  const InviteInitial();
}

/// Estado de carga
class InviteLoading extends InviteState {
  const InviteLoading();
}

/// Estado cuando se ha cargado la información del referido
class InviteLoaded extends InviteState {
  final Referral referral;
  final String? qrCodeData;

  const InviteLoaded({
    required this.referral,
    this.qrCodeData,
  });

  @override
  List<Object?> get props => [referral, qrCodeData];

  InviteLoaded copyWith({
    Referral? referral,
    String? qrCodeData,
  }) {
    return InviteLoaded(
      referral: referral ?? this.referral,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}

/// Estado cuando se ha compartido exitosamente
class InviteShared extends InviteState {
  final String message;

  const InviteShared(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado cuando se ha copiado el enlace
class InviteLinkCopied extends InviteState {
  final String message;

  const InviteLinkCopied(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class InviteError extends InviteState {
  final String message;

  const InviteError(this.message);

  @override
  List<Object?> get props => [message];
}
