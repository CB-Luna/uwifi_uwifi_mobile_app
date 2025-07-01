import 'package:equatable/equatable.dart';

/// Eventos del BLoC de invitaciones
abstract class InviteEvent extends Equatable {
  const InviteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la información del referido del usuario
class LoadUserReferralEvent extends InviteEvent {
  const LoadUserReferralEvent();
}

/// Evento para compartir el enlace de referido
class ShareReferralLinkEvent extends InviteEvent {
  final String referralLink;

  const ShareReferralLinkEvent(this.referralLink);

  @override
  List<Object?> get props => [referralLink];
}

/// Evento para generar código QR
class GenerateQRCodeEvent extends InviteEvent {
  final String referralLink;

  const GenerateQRCodeEvent(this.referralLink);

  @override
  List<Object?> get props => [referralLink];
}

/// Evento para copiar enlace al portapapeles
class CopyReferralLinkEvent extends InviteEvent {
  final String referralLink;

  const CopyReferralLinkEvent(this.referralLink);

  @override
  List<Object?> get props => [referralLink];
}
