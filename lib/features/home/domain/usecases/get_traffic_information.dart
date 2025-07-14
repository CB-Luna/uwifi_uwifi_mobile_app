import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/traffic_data.dart';
import '../repositories/traffic_repository.dart';

class GetTrafficInformation implements UseCase<List<TrafficData>, TrafficParams> {
  final TrafficRepository repository;

  GetTrafficInformation(this.repository);

  @override
  Future<Either<Failure, List<TrafficData>>> call(TrafficParams params) async {
    return await repository.getTrafficInformation(
      params.customerId,
      params.startDate,
      params.endDate,
    );
  }
}

class TrafficParams extends Equatable {
  final String customerId;
  final String startDate;
  final String endDate;

  const TrafficParams({
    required this.customerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [customerId, startDate, endDate];
}
