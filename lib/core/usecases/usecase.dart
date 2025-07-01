import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/failures.dart';

/// Interfaz base para todos los casos de uso
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Clase que representa parámetros vacíos
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
