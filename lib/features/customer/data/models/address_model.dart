import '../../domain/entities/address.dart';
import 'state_model.dart';

class AddressModel extends Address {
  const AddressModel({
    required super.addressId,
    required super.createdAt,
    required super.address1,
    required super.zipcode,
    required super.city,
    required super.stateFk,
    required super.country,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.customerFk,
    required super.address2,
    super.state,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['address_id'],
      createdAt: DateTime.parse(json['created_at']),
      address1: json['address_1'],
      zipcode: json['zipcode'],
      city: json['city'],
      address2: json['address_2'],
      stateFk: json['state_fk'],
      country: json['country'],
      type: json['type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      customerFk: json['customer_fk'],
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'created_at': createdAt.toIso8601String(),
      'address_1': address1,
      'zipcode': zipcode,
      'city': city,
      'address_2': address2,
      'state_fk': stateFk,
      'country': country,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'customer_fk': customerFk,
      'state': state != null ? (state as StateModel).toJson() : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': addressId,
      'street': address1,
      'number': address2,
      'apartment': '',
      'neighborhood': '',
      'city': city,
      'zipcode': zipcode,
      'state': state != null ? (state as StateModel).toJson() : null,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': false,
    };
  }
}
