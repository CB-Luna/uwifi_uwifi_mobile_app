import 'package:equatable/equatable.dart';
import '../../domain/entities/data_usage.dart';

abstract class DataUsageState extends Equatable {
  const DataUsageState();
  
  @override
  List<Object> get props => [];
}

class DataUsageInitial extends DataUsageState {}

class DataUsageLoading extends DataUsageState {}

class DataUsageLoaded extends DataUsageState {
  final DataUsage dataUsage;
  
  const DataUsageLoaded(this.dataUsage);
  
  @override
  List<Object> get props => [dataUsage];
}

class DataUsageError extends DataUsageState {
  final String message;
  
  const DataUsageError(this.message);
  
  @override
  List<Object> get props => [message];
}
