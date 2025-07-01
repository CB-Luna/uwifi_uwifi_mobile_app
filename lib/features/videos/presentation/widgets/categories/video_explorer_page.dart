import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../../../core/utils/app_logger.dart';
import '../../../domain/entities/ad.dart';
import '../../bloc/video_explorer_bloc.dart';
import '../../bloc/video_explorer_event.dart';
import '../../bloc/video_explorer_state.dart';
import 'video_grid_widget.dart';
import 'category_filter_widget.dart';
import 'search_bar_widget.dart';

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
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            context.read<VideoExplorerBloc>().add(
              const FilterByCategory(categoryName: 'Todos'),
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
      '🎬 Video seleccionado desde explorador: ${video.title}',
    );

    context.read<VideoExplorerBloc>().add(
      SelectVideoEvent(videoId: video.id, startIndex: index),
    );
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
                      'Explorar Videos',
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
                            '${state.filteredVideos.length} videos disponibles',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          );
                        }
                        return Text(
                          'Cargando...',
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

  Widget _buildCategoryFilters() {
    return BlocBuilder<VideoExplorerBloc, VideoExplorerState>(
      builder: (context, state) {
        if (state is VideoExplorerLoaded) {
          return CategoryFilterWidget(
            categories: state.categories,
            selectedCategory: state.selectedCategory,
            onCategorySelected: (category) {
              if (category == null) {
                // Mostrar todos los videos
                context.read<VideoExplorerBloc>().add(
                  const FilterByCategory(categoryName: 'Todos'),
                );
              } else {
                // Filtrar por categoría específica
                context.read<VideoExplorerBloc>().add(
                  FilterByCategory(
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                );
              }
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
                  'Cargando videos...',
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
                  'Error al cargar videos',
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
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is VideoExplorerLoaded) {
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
                        ? 'No se encontraron videos'
                        : 'No hay videos disponibles',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'Intenta con otros términos de búsqueda'
                        : 'Selecciona una categoría diferente',
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
