import 'package:equatable/equatable.dart';

abstract class AffiliateState extends Equatable {
  const AffiliateState();

  @override
  List<Object?> get props => [];
}

class AffiliateInitial extends AffiliateState {}

class AffiliateLoading extends AffiliateState {}

class AffiliateSuccess extends AffiliateState {
  final String message;

  const AffiliateSuccess({this.message = 'Invitation sent successfully'});

  @override
  List<Object?> get props => [message];
}

class AffiliateError extends AffiliateState {
  final String message;

  const AffiliateError({required this.message});

  @override
  List<Object?> get props => [message];
}
