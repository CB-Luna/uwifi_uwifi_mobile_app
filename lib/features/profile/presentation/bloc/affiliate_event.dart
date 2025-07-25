import 'package:equatable/equatable.dart';

abstract class AffiliateEvent extends Equatable {
  const AffiliateEvent();

  @override
  List<Object?> get props => [];
}

class SendAffiliateInvitationEvent extends AffiliateEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int customerId;

  const SendAffiliateInvitationEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.customerId,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, phone, customerId];
}
