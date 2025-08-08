import 'package:equatable/equatable.dart';
import '../../domain/entities/data_usage.dart';

abstract class DataUsageState extends Equatable {
  const DataUsageState();
  
  @override
  List<Object> get props => [];
}

class DataUsageInitial extends DataUsageState {}

class DataUsageLoading extends DataUsageState {
  final DataUsage? previousData;
  
  const DataUsageLoading({this.previousData});
  
  @override
  List<Object> get props => previousData != null ? [previousData!] : [];
}

class DataUsageLoaded extends DataUsageState {
  final DataUsage dataUsage;
  final bool fromCache;
  
  const DataUsageLoaded(this.dataUsage, {this.fromCache = false});
  
  @override
  List<Object> get props => [dataUsage, fromCache];
}

class DataUsageError extends DataUsageState {
  final String message;
  
  const DataUsageError(this.message);
  
  @override
  List<Object> get props => [message];
}
