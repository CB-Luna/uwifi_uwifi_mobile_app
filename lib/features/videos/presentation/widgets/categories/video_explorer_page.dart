import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../domain/entities/ad.dart';
import '../../../domain/entities/genre_with_videos.dart';
import '../../bloc/video_explorer_bloc.dart';
import '../../bloc/video_explorer_event.dart';
import '../../bloc/video_explorer_state.dart';
import 'category_filter_widget.dart';
import 'search_bar_widget.dart';
import 'video_grid_widget.dart';

/// Widget principal para explorar videos con filtros y miniaturas
class VideoExplorerPage extends StatefulWidget {
  final Function(Ad video, List<Ad> playlist, int startIndex)? onVideoSelected;
  final VoidCallback? onClose;

  const VideoExplorerPage({super.key, this.onVideoSelected, this.onClose});

  @override
  State<VideoExplorerPage> createState() => _VideoExplorerPageState();
}

class _VideoExplorerPageState extends State<VideoExplorerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Configurar scroll infinito
    _scrollController.addListener(_onScroll);

    // Iniciar animación de entrada
    _animationController.forward();

    // Cargar categorías al inicializar
    Future.microtask(() {
      if (mounted) {
        context.read<VideoExplorerBloc>().add(const LoadCategoriesEvent());
        // ✅ NUEVO: Cargar automáticamente todos los videos al inicio
        // Aumentar el delay para asegurar que las categorías se hayan cargado completamente
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            AppLogger.videoInfo(
              '🚀 Iniciando carga automática de todos los videos',
            );

            // Ocultar el teclado si está abierto
            FocusScope.of(context).unfocus();

            // Enviar evento para cargar todos los videos (categoría "All")
            context.read<VideoExplorerBloc>().add(
              const FilterByCategory(categoryName: 'All', clearCache: true),
            );

            // Log adicional para depuración
            AppLogger.videoInfo(
              '🔍 Evento FilterByCategory enviado con categoryName: All',
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Cargar más videos cuando esté cerca del final
      context.read<VideoExplorerBloc>().add(const LoadMoreVideosEvent());
    }
  }

  void _onVideoTap(Ad video, int index) {
    HapticFeedback.mediumImpact();
    AppLogger.videoInfo(
      '🎬 Video seleccionado desde explorador: ${video.title} (ID: ${video.id})',
    );

    // Buscar el índice correcto del video en la lista filtrada actual
    final currentState = context.read<VideoExplorerBloc>().state;
    if (currentState is VideoExplorerLoaded) {
      // Encontrar el índice exacto del video por ID en la lista filtrada
      final correctIndex = currentState.filteredVideos.indexWhere(
        (v) => v.id == video.id,
      );
      final useIndex = correctIndex >= 0 ? correctIndex : index;

      AppLogger.videoInfo(
        '📊 Índice en grid: $index, Índice correcto en lista: $useIndex',
      );

      context.read<VideoExplorerBloc>().add(
        SelectVideoEvent(videoId: video.id, startIndex: useIndex),
      );
    } else {
      // Si no tenemos el estado cargado, usar el índice original
      context.read<VideoExplorerBloc>().add(
        SelectVideoEvent(videoId: video.id, startIndex: index),
      );
    }
  }

  void _closeExplorer() {
    _animationController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoExplorerBloc, VideoExplorerState>(
      listener: (context, state) {
        if (state is VideoSelectedForPlayback) {
          // Cerrar explorador y reproducir video
          _animationController.reverse().then((_) {
            widget.onVideoSelected?.call(
              state.selectedVideo,
              state.playlist,
              state.startIndex,
            );
            widget.onClose?.call();
          });
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.9 * _fadeAnimation.value),
            child: Column(
              children: [
                // Spacer para empujar contenido hacia abajo
                const Spacer(),

                // Contenedor principal
                Transform.translate(
                  offset: Offset(
                    0,
                    MediaQuery.of(context).size.height * _slideAnimation.value,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.95,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0A0A),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header con barra de búsqueda
                        _buildHeader(),

                        // Filtros de categorías
                        _buildCategoryFilters(),

                        // Grid de videos
                        Expanded(child: _buildVideoGrid()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF0A0A0A).withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Título y botón cerrar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BlocBuilder<VideoExplorerBloc, VideoExplorerState>(
                      builder: (context, state) {
                        if (state is VideoExplorerLoaded) {
                          return Text(
                            '${state.filteredVideos.length} available videos',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          );
                        }
                        return Text(
                          'Loading...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: _closeExplorer,
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Barra de búsqueda
          SearchBarWidget(
            controller: _searchController,
            onChanged: (query) {
              context.read<VideoExplorerBloc>().add(SearchVideosEvent(query));
            },
            onClear: () {
              _searchController.clear();
              context.read<VideoExplorerBloc>().add(
                const SearchVideosEvent(''),
              );
            },
          ),
        ],
      ),
    );
  }

  // Mantener una referencia al estado actual del filtro seleccionado
  GenreWithVideos? _currentSelectedCategory;

  Widget _buildCategoryFilters() {
    return BlocConsumer<VideoExplorerBloc, VideoExplorerState>(
      listenWhen: (previous, current) {
        // Solo escuchar cuando cambia selectedCategory
        if (previous is VideoExplorerLoaded && current is VideoExplorerLoaded) {
          return previous.selectedCategory != current.selectedCategory;
        }
        return false;
      },
      listener: (context, state) {
        if (state is VideoExplorerLoaded) {
          // Actualizar la referencia local
          _currentSelectedCategory = state.selectedCategory;
          AppLogger.videoInfo(
            '📢 LISTENER - Actualizado _currentSelectedCategory a: ${_currentSelectedCategory?.name ?? "null"}',
          );
        }
      },
      buildWhen: (previous, current) {
        // Reconstruir en cualquier cambio de estado
        return true;
      },
      builder: (context, state) {
        if (state is VideoExplorerLoaded) {
          // Ordenar las categorías alfabéticamente por nombre
          final sortedCategories = List<GenreWithVideos>.from(state.categories)
            ..sort((a, b) => a.name.compareTo(b.name));

          // Registrar en log para depuración
          AppLogger.videoInfo(
            'Categorías ordenadas alfabéticamente: ${sortedCategories.map((c) => c.name).join(', ')}',
          );

          // Log del estado actual
          AppLogger.videoInfo(
            '📢 WIDGET - Estado actual: selectedCategory: ${state.selectedCategory?.name ?? "null"}',
          );
          AppLogger.videoInfo(
            '📢 WIDGET - Referencia local: _currentSelectedCategory: ${_currentSelectedCategory?.name ?? "null"}',
          );

          // Usar la referencia local para el estado seleccionado
          // Esto asegura que el widget siempre tenga el estado más actualizado
          return CategoryFilterWidget(
            categories: sortedCategories, // Usar la lista ordenada
            selectedCategory:
                _currentSelectedCategory, // Usar la referencia local en lugar de state.selectedCategory
            onCategorySelected: (category) {
              // Ocultar el teclado si está abierto
              FocusScope.of(context).unfocus();

              // Log detallado antes de enviar el evento
              AppLogger.videoInfo(
                '📍 Iniciando selección de categoría: ${category?.name ?? "All"}',
              );

              // Actualizar inmediatamente la referencia local para una respuesta visual inmediata
              setState(() {
                _currentSelectedCategory = category;
                AppLogger.videoInfo(
                  '🔄 Actualizando _currentSelectedCategory inmediatamente a: ${_currentSelectedCategory?.name ?? "null"}',
                );
              });

              if (category == null) {
                // Show all videos
                AppLogger.videoInfo(
                  '📡 Enviando evento FilterByCategory con categoryName: "All"',
                );
                context.read<VideoExplorerBloc>().add(
                  const FilterByCategory(categoryName: 'All'),
                );
              } else {
                // Filter by specific category
                AppLogger.videoInfo(
                  '📡 Enviando evento FilterByCategory con categoryId: ${category.id}, categoryName: "${category.name}"',
                );
                context.read<VideoExplorerBloc>().add(
                  FilterByCategory(
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                );
              }

              // Registrar acción completa para depuración
              AppLogger.videoInfo(
                '✅ Categoría seleccionada: ${category?.name ?? "All"}, teclado ocultado, evento enviado al bloc',
              );

              // Vibrar para dar feedback táctil al usuario
              HapticFeedback.selectionClick();
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildVideoGrid() {
    return BlocBuilder<VideoExplorerBloc, VideoExplorerState>(
      builder: (context, state) {
        if (state is VideoExplorerLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                SizedBox(height: 16),
                Text(
                  'Loading videos...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          );
        }

        if (state is VideoExplorerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.withValues(alpha: 0.8),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading videos',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<VideoExplorerBloc>().add(
                      const RefreshVideosEvent(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is VideoExplorerLoaded) {
          // Log para verificar la cantidad de videos cargados
          AppLogger.videoInfo(
            '📊 Mostrando ${state.filteredVideos.length} videos en UI',
          );

          if (state.filteredVideos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.searchQuery.isNotEmpty
                        ? Icons.search_off
                        : Icons.video_library_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'No videos found'
                        : 'No videos available',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'Try different search terms'
                        : 'Select a different category',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return VideoGridWidget(
            videos: state.filteredVideos,
            scrollController: _scrollController,
            onVideoTap: _onVideoTap,
            isLoadingMore: state.isLoadingMore,
            isRefreshing: state.isRefreshing,
            onRefresh: () {
              context.read<VideoExplorerBloc>().add(const RefreshVideosEvent());
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
