import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/app_logger.dart';
import '../../data/datasources/video_search_service.dart';
import '../../domain/entities/ad.dart';
import '../../domain/entities/genre_with_videos.dart';
import '../../domain/usecases/get_ads.dart';
import '../../domain/usecases/get_ads_with_params.dart';
import '../../domain/usecases/get_genres_with_videos.dart';
import 'video_explorer_event.dart';
import 'video_explorer_state.dart';

/// BLoC para la exploración y filtrado de videos
class VideoExplorerBloc extends Bloc<VideoExplorerEvent, VideoExplorerState> {
  final GetAds getAdsUseCase;
  final GetAdsWithParams getAdsWithParamsUseCase;
  final GetGenresWithVideos getGenresWithVideosUseCase;
  final VideoSearchService videoSearchService;

  // Cache para optimizar rendimiento
  final Map<String, List<Ad>> _videoCache = {};
  final Map<int, List<Ad>> _categoryCache = {};
  List<GenreWithVideos> _categoriesCache = [];

  VideoExplorerBloc({
    required this.getAdsUseCase,
    required this.getAdsWithParamsUseCase,
    required this.getGenresWithVideosUseCase,
    required this.videoSearchService,
  }) : super(const VideoExplorerInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchVideosEvent>(_onSearchVideos);
    on<LoadMoreVideosEvent>(_onLoadMoreVideos);
    on<RefreshVideosEvent>(_onRefreshVideos);
    on<SelectVideoEvent>(_onSelectVideo);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  /// Cargar categorías disponibles
  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    emit(const VideoExplorerLoading());

    try {
      AppLogger.videoInfo('🔄 Cargando categorías para explorador...');

      // Intentar usar cache primero
      if (_categoriesCache.isNotEmpty) {
        AppLogger.videoInfo('✅ Usando categorías desde cache');
        emit(
          VideoExplorerLoaded(
            categories: _categoriesCache,
            videos: const [],
            filteredVideos: const [],
          ),
        );
        return;
      }

      final result = await getGenresWithVideosUseCase(NoParams());

      result.fold(
        (failure) {
          AppLogger.videoError(
            '❌ Error cargando categorías: ${_mapFailureToMessage(failure)}',
          );
          emit(
            VideoExplorerError(
              message: _mapFailureToMessage(failure),
              errorCode: failure.runtimeType.toString(),
            ),
          );
        },
        (categories) {
          _categoriesCache = categories;
          AppLogger.videoInfo('✅ Categorías cargadas: ${categories.length}');

          emit(
            VideoExplorerLoaded(
              categories: categories,
              videos: const [],
              filteredVideos: const [],
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.videoError('❌ Error inesperado cargando categorías: $e');
      emit(
        const VideoExplorerError(
          message: 'Error inesperado al cargar categorías',
          errorCode: 'UNEXPECTED_ERROR',
        ),
      );
    }
  }

  /// Filtrar videos por categoría
  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    try {
      AppLogger.videoInfo(
        '🔍 Filtrando por categoría: ${event.categoryName} (ID: ${event.categoryId})',
      );

      // Mostrar estado de carga
      emit(currentState.copyWith(isRefreshing: true));

      String cacheKey = 'category_${event.categoryId ?? 'all'}';

      // Verificar cache si no se solicita limpiar
      if (!event.clearCache && _videoCache.containsKey(cacheKey)) {
        AppLogger.videoInfo(
          '✅ Usando videos desde cache para: ${event.categoryName}',
        );
        final cachedVideos = _videoCache[cacheKey]!;

        // Encontrar categoría seleccionada
        GenreWithVideos? selectedCategory;
        
        // Si es la categoría "All", establecer explícitamente a null
        if (event.categoryName == 'All' || event.categoryId == null) {
          selectedCategory = null;
          AppLogger.videoInfo('📍 BLOC CACHE - Categoría "All" seleccionada, estableciendo selectedCategory a null');
        } else {
          // Para otras categorías, buscar por ID
          selectedCategory = currentState.categories.firstWhere(
            (cat) => cat.id == event.categoryId,
            orElse: () => currentState.categories.first,
          );
        }
        
        AppLogger.videoInfo('📍 BLOC CACHE - Emitiendo estado con selectedCategory: ${selectedCategory?.name ?? "null"}');

        emit(
          currentState.copyWith(
            filteredVideos: cachedVideos,
            selectedCategory: selectedCategory,
            searchQuery: '',
            isRefreshing: false,
            currentPage: 1,
            hasMoreVideos: cachedVideos.length >= 20,
          ),
        );
        return;
      }

      // Cargar videos desde el servidor
      Either<Failure, List<Ad>> result;

      if (event.categoryId == null) {
        // Cargar todos los videos
        result = await getAdsWithParamsUseCase(
          const GetAdsParams(),
        );
      } else {
        // Cargar videos por categoría
        result = await getAdsWithParamsUseCase(
          GetAdsParams(categoryId: event.categoryId),
        );
      }

      result.fold(
        (failure) {
          AppLogger.videoError(
            '❌ Error filtrando videos: ${_mapFailureToMessage(failure)}',
          );
          emit(currentState.copyWith(isRefreshing: false));
          emit(
            VideoExplorerError(
              message: _mapFailureToMessage(failure),
              errorCode: failure.runtimeType.toString(),
            ),
          );
        },
        (videos) {
          // Guardar en cache
          _videoCache[cacheKey] = videos;

          // Encontrar categoría seleccionada
          GenreWithVideos? selectedCategory;
          
          // Si es la categoría "All", establecer explícitamente a null
          if (event.categoryName == 'All' || event.categoryId == null) {
            selectedCategory = null;
            AppLogger.videoInfo('📍 BLOC - Categoría "All" seleccionada, estableciendo selectedCategory a null');
          } else {
            // Para otras categorías, buscar por ID
            selectedCategory = currentState.categories.firstWhere(
              (cat) => cat.id == event.categoryId,
              orElse: () => currentState.categories.first,
            );
          }
          
          // Log para depurar el estado de selectedCategory
          AppLogger.videoInfo(
            '📍 BLOC - Estableciendo selectedCategory: ${selectedCategory?.name ?? "null"} para evento con categoryName: ${event.categoryName}',
          );

          // Log detallado del resultado de filtrado
          AppLogger.videoInfo(
            '📊 Resultado del filtrado - Categoría: ${event.categoryName} (ID: ${event.categoryId})',
          );
          AppLogger.videoInfo(
            '📂 Total videos encontrados: ${videos.length}',
          );
          AppLogger.videoInfo(
            '✅ Videos filtrados exitosamente para ${event.categoryName}',
          );

          emit(
            currentState.copyWith(
              filteredVideos: videos,
              selectedCategory: selectedCategory,
              searchQuery: '',
              isRefreshing: false,
              currentPage: 1,
              hasMoreVideos: videos.length >= 20,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.videoError('❌ Error inesperado filtrando videos: $e');
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  /// Buscar videos por texto usando el servicio RPC de Supabase
  Future<void> _onSearchVideos(
    SearchVideosEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    try {
      AppLogger.videoInfo('🔍 Buscando videos con RPC: "${event.query}"');

      // Si la consulta está vacía, mostrar todos los videos
      if (event.query.isEmpty) {
        emit(
          currentState.copyWith(
            searchQuery: '',
            filteredVideos: currentState.videos,
            isRefreshing: false,
          ),
        );
        return;
      }

      // Mostrar estado de carga
      emit(currentState.copyWith(isRefreshing: true));

      // Usar el servicio de búsqueda RPC
      final searchResults = await videoSearchService.searchVideos(event.query);

      // Actualizar el estado con los resultados de la búsqueda
      emit(
        currentState.copyWith(
          searchQuery: event.query,
          filteredVideos: searchResults,
          isRefreshing: false,
        ),
      );

      AppLogger.videoInfo(
        '✅ Búsqueda RPC completada: ${searchResults.length} resultados',
      );
    } catch (e) {
      AppLogger.videoError('❌ Error en búsqueda RPC: $e');
      // En caso de error, mantener el estado actual pero quitar el indicador de carga
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  /// Cargar más videos (paginación)
  Future<void> _onLoadMoreVideos(
    LoadMoreVideosEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    if (currentState.isLoadingMore || !currentState.hasMoreVideos) {
      return;
    }

    try {
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;
      final categoryId = currentState.selectedCategory?.id;

      AppLogger.videoInfo(
        '📄 Cargando página $nextPage para categoría: ${categoryId ?? "todas"}',
      );

      final result = await getAdsWithParamsUseCase(
        GetAdsParams(page: nextPage, categoryId: categoryId),
      );

      result.fold(
        (failure) {
          AppLogger.videoError(
            '❌ Error cargando más videos: ${_mapFailureToMessage(failure)}',
          );
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (newVideos) {
          final updatedVideos = [...currentState.filteredVideos, ...newVideos];

          // Actualizar cache
          String cacheKey = 'category_${categoryId ?? 'all'}';
          _videoCache[cacheKey] = updatedVideos;

          AppLogger.videoInfo(
            '✅ Más videos cargados: ${newVideos.length} nuevos, ${updatedVideos.length} total',
          );

          emit(
            currentState.copyWith(
              filteredVideos: updatedVideos,
              isLoadingMore: false,
              currentPage: nextPage,
              hasMoreVideos: newVideos.length >= 20,
            ),
          );
        },
      );
    } catch (e) {
      AppLogger.videoError('❌ Error inesperado cargando más videos: $e');
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Refrescar videos
  Future<void> _onRefreshVideos(
    RefreshVideosEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    // Limpiar cache y recargar
    _videoCache.clear();
    _categoryCache.clear();

    if (currentState.selectedCategory != null) {
      add(
        FilterByCategory(
          categoryId: currentState.selectedCategory!.id,
          categoryName: currentState.selectedCategory!.name,
          clearCache: true,
        ),
      );
    } else {
      add(const FilterByCategory(categoryName: 'Todos', clearCache: true));
    }
  }

  /// Seleccionar video para reproducir
  Future<void> _onSelectVideo(
    SelectVideoEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    try {
      // Buscar el video seleccionado
      final selectedVideo = currentState.filteredVideos.firstWhere(
        (video) => video.id == event.videoId,
      );

      AppLogger.videoInfo('🎬 Video seleccionado: ${selectedVideo.title}');

      emit(
        VideoSelectedForPlayback(
          selectedVideo: selectedVideo,
          playlist: currentState.filteredVideos,
          startIndex: event.startIndex,
        ),
      );
    } catch (e) {
      AppLogger.videoError('❌ Error seleccionando video: $e');
    }
  }

  /// Limpiar filtros
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<VideoExplorerState> emit,
  ) async {
    if (state is! VideoExplorerLoaded) return;

    final currentState = state as VideoExplorerLoaded;

    emit(
      currentState.copyWith(
        searchQuery: '',
        filteredVideos: currentState.videos,
        clearCategory: true,
      ),
    );

    AppLogger.videoInfo('🧹 Filtros limpiados');
  }

  /// Mapear errores a mensajes de usuario
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Error de conexión con el servidor';
      case CacheFailure _:
        return 'Error al acceder a los datos locales';
      case NetworkFailure _:
        return 'Verifique su conexión a internet';
      default:
        return 'Ha ocurrido un error inesperado';
    }
  }

  @override
  Future<void> close() {
    _videoCache.clear();
    _categoryCache.clear();
    _categoriesCache.clear();
    return super.close();
  }
}
