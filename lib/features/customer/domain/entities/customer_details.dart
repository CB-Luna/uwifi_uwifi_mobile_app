import 'package:equatable/equatable.dart';

import 'address.dart';
import 'billing_cycle.dart';
import 'note.dart';
import 'service.dart';

class CustomerDetails extends Equatable {
  final int customerId;
  final DateTime createdAt;
  final String firstName;
  final String lastName;
  final String status;
  final String email;
  final String mobilePhone;
  final String sharedLinkId;
  final String? userPhoto;
  final Address? billingAddress;
  final Address? physicalAddress;
  final BillingCycle? billingCycle;
  final num balance;
  final List<Service> services;
  final List<Note> notes;
  final int customerAfiliateId;

  const CustomerDetails({
    required this.customerId,
    required this.createdAt,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.email,
    required this.mobilePhone,
    required this.sharedLinkId,
    required this.billingAddress,
    required this.physicalAddress,
    required this.billingCycle,
    required this.balance,
    required this.services,
    required this.notes,
    required this.customerAfiliateId,
    this.userPhoto,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    customerId,
    createdAt,
    firstName,
    lastName,
    status,
    email,
    mobilePhone,
    sharedLinkId,
    userPhoto,
    billingAddress,
    physicalAddress,
    billingCycle,
    balance,
    services,
    notes,
    customerAfiliateId,
  ];
}
