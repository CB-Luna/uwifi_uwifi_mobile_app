import 'package:equatable/equatable.dart';

import '../../../customer/domain/entities/customer_details.dart';

/// Eventos del BLoC de invitaciones
abstract class InviteEvent extends Equatable {
  const InviteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la información del referido del usuario
class LoadUserReferralEvent extends InviteEvent {
  /// Detalles del cliente para usar el sharedLinkId como código de referido
  final CustomerDetails? customerDetails;

  const LoadUserReferralEvent({this.customerDetails});

  @override
  List<Object?> get props => [customerDetails];
}

/// Evento para compartir el enlace de referido
class ShareReferralLinkEvent extends InviteEvent {
  final String referralLink;
  /// Detalles del cliente para mantener el contexto
  final CustomerDetails? customerDetails;

  const ShareReferralLinkEvent(this.referralLink, {this.customerDetails});

  @override
  List<Object?> get props => [referralLink, customerDetails];
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
  /// Detalles del cliente para mantener el contexto
  final CustomerDetails? customerDetails;

  const CopyReferralLinkEvent(this.referralLink, {this.customerDetails});

  @override
  List<Object?> get props => [referralLink, customerDetails];
}
