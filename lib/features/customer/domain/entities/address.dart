import 'package:equatable/equatable.dart';

import 'state.dart';

class Address extends Equatable {
  final int addressId;
  final DateTime createdAt;
  final String address1;
  final String zipcode;
  final String city;
  final String? address2;
  final int stateFk;
  final String country;
  final String type;
  final double latitude;
  final double longitude;
  final int customerFk;
  final State? state;

  const Address({
    required this.addressId,
    required this.createdAt,
    required this.address1,
    required this.zipcode,
    required this.city,
    required this.stateFk,
    required this.country,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.customerFk,
    this.address2,
    this.state,
  });

  String get formattedAddress {
    final line1 = address1;
    final line2 = address2 != null && address2!.isNotEmpty ? ', $address2' : '';
    final cityStateZip = '$city, ${state?.code ?? ''} $zipcode';
    return '$line1$line2, $cityStateZip';
  }

  @override
  List<Object?> get props => [
    addressId,
    createdAt,
    address1,
    zipcode,
    city,
    address2,
    stateFk,
    country,
    type,
    latitude,
    longitude,
    customerFk,
    state,
  ];
}
