import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_genres.dart';
import 'genres_event.dart';
import 'genres_state.dart';

class GenresBloc extends Bloc<GenresEvent, GenresState> {
  final GetGenres getGenres;

  GenresBloc({required this.getGenres}) : super(const GenresInitial()) {
    on<LoadGenresEvent>(_onLoadGenres);
    on<LoadGenreEvent>(_onLoadGenre);
  }

  Future<void> _onLoadGenres(
    LoadGenresEvent event,
    Emitter<GenresState> emit,
  ) async {
    emit(const GenresLoading());

    final result = await getGenres(NoParams());

    result.fold(
      (failure) {
        AppLogger.categoryInfo(
          'Error al cargar géneros: ${failure.toString()}',
        );
        emit(GenresError(message: _mapFailureToMessage(failure)));
      },
      (genres) {
        AppLogger.categoryInfo('Géneros cargados: ${genres.length} categorías');
        emit(GenresLoaded(genres: genres));
      },
    );
  }

  Future<void> _onLoadGenre(
    LoadGenreEvent event,
    Emitter<GenresState> emit,
  ) async {
    // Si ya tenemos géneros cargados, buscar en la lista actual
    if (state is GenresLoaded) {
      final currentGenres = (state as GenresLoaded).genres;
      final genre = currentGenres.firstWhere(
        (g) => g.id == event.genreId,
        orElse: () => throw Exception('Género no encontrado'),
      );
      emit(GenreLoaded(genre: genre));
      return;
    }

    // Si no tenemos géneros cargados, cargar todos primero
    add(const LoadGenresEvent());
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Error de servidor al cargar categorías';
      case CacheFailure _:
        return 'Error de caché al cargar categorías';
      case NetworkFailure _:
        return 'No hay conexión a internet';
      default:
        return 'Error inesperado al cargar categorías';
    }
  }
}
