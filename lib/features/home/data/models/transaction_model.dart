import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.transactionId,
    required super.customerId,
    required super.createdAt,
    required super.transactionTypeFk,
    required super.amount,
    super.serviceFk,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'] as int,
      customerId: json['customer_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      transactionTypeFk: json['transaction_type_fk'] as int,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'] as double,
      serviceFk: json['service_fk'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'customer_id': customerId,
      'created_at': createdAt.toIso8601String(),
      'transaction_type_fk': transactionTypeFk,
      'amount': amount,
      'service_fk': serviceFk,
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      transactionId: transaction.transactionId,
      customerId: transaction.customerId,
      createdAt: transaction.createdAt,
      transactionTypeFk: transaction.transactionTypeFk,
      amount: transaction.amount,
      serviceFk: transaction.serviceFk,
    );
  }
}
