import '../../domain/entities/customer_points.dart';

class CustomerPointsModel extends CustomerPoints {
  const CustomerPointsModel({
    required int customerId,
    required int principalPoints,
    required int affiliatePoints,
    required int totalPointsEarned,
    required int secondsWatched,
    required List<int> adsWatched,
    required List<int> affiliatesArray,
    required String billingStart,
    required String billingEnd,
  }) : super(
          customerId: customerId,
          principalPoints: principalPoints,
          affiliatePoints: affiliatePoints,
          totalPointsEarned: totalPointsEarned,
          secondsWatched: secondsWatched,
          adsWatched: adsWatched,
          affiliatesArray: affiliatesArray,
          billingStart: billingStart,
          billingEnd: billingEnd,
        );

  factory CustomerPointsModel.fromJson(Map<String, dynamic> json) {
    return CustomerPointsModel(
      customerId: json['customer_id'] as int,
      principalPoints: json['principal_points'] as int,
      affiliatePoints: json['affiliate_points'] as int,
      totalPointsEarned: json['total_points_earned'] as int,
      secondsWatched: json['seconds_watched'] as int,
      adsWatched: List<int>.from(json['ads_watched'] as List),
      affiliatesArray: List<int>.from(json['affiliates_array'] as List),
      billingStart: json['billing_start'] as String,
      billingEnd: json['billing_end'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'principal_points': principalPoints,
      'affiliate_points': affiliatePoints,
      'total_points_earned': totalPointsEarned,
      'seconds_watched': secondsWatched,
      'ads_watched': adsWatched,
      'affiliates_array': affiliatesArray,
      'billing_start': billingStart,
      'billing_end': billingEnd,
    };
  }
}
