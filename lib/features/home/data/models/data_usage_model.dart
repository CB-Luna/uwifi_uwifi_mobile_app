import '../../domain/entities/data_usage.dart';

class DataUsageModel extends DataUsage {
  const DataUsageModel({
    required super.monthlyTx,
    required super.monthlyRx,
    required super.monthlyTotal,
  });

  factory DataUsageModel.fromJson(Map<String, dynamic> json) {
    return DataUsageModel(
      monthlyTx: json['monthlyTx'] as int,
      monthlyRx: json['monthlyRx'] as int,
      monthlyTotal: json['monthlyTotal'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlyTx': monthlyTx,
      'monthlyRx': monthlyRx,
      'monthlyTotal': monthlyTotal,
    };
  }
}
