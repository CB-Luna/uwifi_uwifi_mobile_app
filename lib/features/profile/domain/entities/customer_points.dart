import 'package:equatable/equatable.dart';

class CustomerPoints extends Equatable {
  final int customerId;
  final int principalPoints;
  final int affiliatePoints;
  final int totalPointsEarned;
  final int secondsWatched;
  final List<String> adsWatched;
  final List<String> adsLiked;
  final List<int> affiliatesArray;
  final String billingStart;
  final String billingEnd;

  const CustomerPoints({
    required this.customerId,
    required this.principalPoints,
    required this.affiliatePoints,
    required this.totalPointsEarned,
    required this.secondsWatched,
    required this.adsWatched,
    required this.adsLiked,
    required this.affiliatesArray,
    required this.billingStart,
    required this.billingEnd,
  });

  @override
  List<Object?> get props => [
        customerId,
        principalPoints,
        affiliatePoints,
        totalPointsEarned,
        secondsWatched,
        adsWatched,
        adsLiked,
        affiliatesArray,
        billingStart,
        billingEnd,
      ];
}
