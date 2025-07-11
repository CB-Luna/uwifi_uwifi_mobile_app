import 'package:equatable/equatable.dart';

class AffiliatedUser extends Equatable {
  final int customerId;
  final String customerName;
  final bool isAffiliate;

  const AffiliatedUser({
    required this.customerId,
    required this.customerName,
    required this.isAffiliate,
  });

  @override
  List<Object?> get props => [customerId, customerName, isAffiliate];

  // Método para obtener las iniciales del nombre
  String get initials {
    final nameParts = customerName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.isNotEmpty) {
      return nameParts[0].length > 1 ? nameParts[0].substring(0, 2) : nameParts[0];
    }
    return 'NA';
  }
}
