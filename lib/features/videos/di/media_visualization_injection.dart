import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/media_visualization_remote_data_source.dart';
import '../data/datasources/media_visualization_remote_data_source_impl.dart';
import '../data/datasources/video_search_service.dart';
import '../data/repositories/media_visualization_repository_impl.dart';
import '../domain/repositories/media_visualization_repository.dart';
import '../domain/usecases/register_media_visualization.dart';

/// Registra las dependencias relacionadas con la visualización de medios
void registerMediaVisualizationDependencies(GetIt getIt) {
  // Services
  getIt.registerLazySingleton<VideoSearchService>(
    () => VideoSearchService(supabaseClient: getIt<SupabaseClient>(instanceName: 'mediaLibraryClient')),
  );

  // Use cases
  getIt.registerLazySingleton(() => RegisterMediaVisualization(getIt()));

  // Repository
  getIt.registerLazySingleton<MediaVisualizationRepository>(
    () => MediaVisualizationRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Data sources
  getIt.registerLazySingleton<MediaVisualizationRemoteDataSource>(
    () => MediaVisualizationRemoteDataSourceImpl(
      transactionsClient: getIt<SupabaseClient>(instanceName: 'transactionsClient'),
    ),
  );
}
