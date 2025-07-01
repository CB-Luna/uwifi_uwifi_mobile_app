import 'package:equatable/equatable.dart';

abstract class GenresEvent extends Equatable {
  const GenresEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todas las categorías
class LoadGenresEvent extends GenresEvent {
  const LoadGenresEvent();
}

/// Evento para cargar una categoría específica
class LoadGenreEvent extends GenresEvent {
  final int genreId;

  const LoadGenreEvent(this.genreId);

  @override
  List<Object?> get props => [genreId];
}
