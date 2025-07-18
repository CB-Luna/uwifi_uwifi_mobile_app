import '../../domain/entities/customer_details.dart';
import 'address_model.dart';
import 'billing_cycle_model.dart';
import 'note_model.dart';
import 'service_model.dart';

class CustomerDetailsModel extends CustomerDetails {
  const CustomerDetailsModel({
    required super.customerId,
    required super.createdAt,
    required super.firstName,
    required super.lastName,
    required super.status,
    required super.email,
    required super.mobilePhone,
    required super.sharedLinkId,
    required super.billingAddress,
    required super.physicalAddress,
    required super.billingCycle,
    required super.balance,
    required super.services,
    required super.notes,
    super.userPhoto,
  });

  factory CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsModel(
      customerId: json['customer_id'],
      createdAt: DateTime.parse(json['created_at']),
      firstName: json['first_name'],
      lastName: json['last_name'],
      status: json['status'],
      email: json['email'],
      mobilePhone: json['mobile_phone'],
      sharedLinkId: json['shared_link_id'],
      userPhoto: json['userphoto'],
      billingAddress: json['billing_address'] != null
          ? AddressModel.fromJson(json['billing_address'])
          : null,
      physicalAddress: json['physical_address'] != null
          ? AddressModel.fromJson(json['physical_address'])
          : null,
      billingCycle: json['billing_cycle'] != null
          ? BillingCycleModel.fromJson(json['billing_cycle'])
          : null,
      balance: json['balance'],
      services: (json['services'] as List)
          .map((service) => ServiceModel.fromJson(service))
          .toList(),
      notes: (json['notes'] as List)
          .map((note) => NoteModel.fromJson(note))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'created_at': createdAt.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'status': status,
      'email': email,
      'mobile_phone': mobilePhone,
      'shared_link_id': sharedLinkId,
      'userphoto': userPhoto,
      'billing_address': billingAddress != null
          ? (billingAddress is AddressModel
                ? (billingAddress as AddressModel).toJson()
                : null)
          : null,
      'physical_address': physicalAddress != null
          ? (physicalAddress is AddressModel
                ? (physicalAddress as AddressModel).toJson()
                : null)
          : null,
      'billing_cycle': billingCycle != null
          ? (billingCycle is BillingCycleModel
                ? (billingCycle as BillingCycleModel).toJson()
                : null)
          : null,
      'balance': balance,
      'services': services
          .map((service) => service is ServiceModel ? service.toJson() : null)
          .whereType<Map<String, dynamic>>()
          .toList(),
      'notes': notes
          .map((note) => note is NoteModel ? note.toJson() : null)
          .whereType<Map<String, dynamic>>()
          .toList(),
    };
  }

  factory CustomerDetailsModel.fromEntity(CustomerDetails entity) {
    return CustomerDetailsModel(
      customerId: entity.customerId,
      createdAt: entity.createdAt,
      firstName: entity.firstName,
      lastName: entity.lastName,
      status: entity.status,
      email: entity.email,
      mobilePhone: entity.mobilePhone,
      sharedLinkId: entity.sharedLinkId,
      userPhoto: entity.userPhoto,
      billingAddress: entity.billingAddress,
      physicalAddress: entity.physicalAddress,
      billingCycle: entity.billingCycle,
      balance: entity.balance,
      services: entity.services,
      notes: entity.notes,
    );
  }
}
