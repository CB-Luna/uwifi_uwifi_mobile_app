import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/genre_model.dart';
import 'genres_remote_data_source.dart';

class GenresRemoteDataSourceImpl implements GenresRemoteDataSource {
  final SupabaseClient supabaseClient;

  GenresRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<GenreModel>> getGenres() async {
    try {
      final response = await supabaseClient
          .from('genre_ad')
          .select(
            'id, name, description, poster_img, poster_img_file, visible, created_at, updated_at',
          )
          .order('name');

      return (response as List)
          .map((genre) => GenreModel.fromJson(genre))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<GenreModel>> getVisibleGenres() async {
    try {
      final response = await supabaseClient
          .from('genre_ad')
          .select(
            'id, name, description, poster_img, poster_img_file, visible, created_at, updated_at',
          )
          .eq('visible', true)
          .order('name');

      return (response as List)
          .map((genre) => GenreModel.fromJson(genre))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<GenreModel> getGenre(int id) async {
    try {
      final response = await supabaseClient
          .from('genre_ad')
          .select(
            'id, name, description, poster_img, poster_img_file, visible, created_at, updated_at',
          )
          .eq('id', id)
          .single();

      return GenreModel.fromJson(response);
    } catch (e) {
      throw ServerException();
    }
  }
}
