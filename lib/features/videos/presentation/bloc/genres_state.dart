import 'package:equatable/equatable.dart';

import '../../domain/entities/genre_with_videos.dart';

abstract class GenresState extends Equatable {
  const GenresState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial del BLoC de géneros
class GenresInitial extends GenresState {
  const GenresInitial();
}

/// Estado que indica que los géneros están siendo cargados
class GenresLoading extends GenresState {
  const GenresLoading();
}

/// Estado que contiene los géneros cargados con sus videos
class GenresLoaded extends GenresState {
  final List<GenreWithVideos> genres;

  const GenresLoaded({required this.genres});

  @override
  List<Object?> get props => [genres];

  GenresLoaded copyWith({List<GenreWithVideos>? genres}) {
    return GenresLoaded(genres: genres ?? this.genres);
  }
}

/// Estado que contiene un solo género con sus videos
class GenreLoaded extends GenresState {
  final GenreWithVideos genre;

  const GenreLoaded({required this.genre});

  @override
  List<Object?> get props => [genre];
}

/// Estado que indica un error en la carga de géneros
class GenresError extends GenresState {
  final String message;

  const GenresError({required this.message});

  @override
  List<Object?> get props => [message];
}
