import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../injection_container.dart' as di;

import '../../../../core/utils/app_logger.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/bloc/wallet_bloc.dart';
import '../../../profile/presentation/bloc/wallet_event.dart';
import '../../domain/entities/ad.dart';
import '../bloc/genres_bloc.dart';
import '../bloc/genres_event.dart';
import '../bloc/genres_state.dart';
import '../bloc/video_explorer_bloc.dart';
import '../widgets/categories/video_explorer_page.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import '../managers/tiktok_video_manager.dart';
import '../widgets/categories/video_explorer_button.dart';
import '../widgets/categories/video_info_bottom_sheet.dart';
import '../widgets/coins/coins_action_widget.dart';
import '../widgets/likes/like_action_widget.dart';
import '../widgets/progressindicator/smart_video_progress_indicator.dart';
import '../widgets/tiktok_video_player.dart';
import 'video_completion_handler.dart';

/// Main TikTok/Instagram style video feed page - CLEAN AND FUNCTIONAL
class TikTokVideoFeedPage extends StatefulWidget {
  const TikTokVideoFeedPage({super.key});

  @override
  State<TikTokVideoFeedPage> createState() => _TikTokVideoFeedPageState();
}

class _TikTokVideoFeedPageState extends State<TikTokVideoFeedPage> {
  late PageController _pageController;
  late TikTokVideoManager _videoManager;
  int _currentIndex = 0;
  VideoPlayerController? _currentVideoController;

  // Para controlar el estilo del indicador de progreso
  ProgressIndicatorStyle _currentProgressStyle =
      ProgressIndicatorStyle.glassmorphism;

  // Flag para prevenir carga automática después de selección manual
  bool _manualSelectionActive = false;

  // Key para forzar recreación del PageView
  Key _pageViewKey = UniqueKey();
  
  // Variables para la navegación entre categorías
  List<String> _categoryIds = [];
  List<String> _categoryNames = [];
  bool _isSwipingCategory = false;
  double _horizontalDragStartPosition = 0;
  double _horizontalDragEndPosition = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _videoManager = TikTokVideoManager();
    _videoManager.addListener(_onVideoManagerChanged);

    // ✅ INITIALIZE the points system
    VideoCompletionHandler.loadUserPointsFromStorage();

    // Load initial videos and wallet data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_manualSelectionActive) {
        context.read<VideosBloc>().add(const LoadVideosPaginatedEvent());
        
        // Get customer ID and load wallet data
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          if (authState.user.customerId != null) {
            final customerId = authState.user.customerId.toString();
            AppLogger.videoInfo('🪙 Loading wallet points with customerId: $customerId (numeric ID)');
            context.read<WalletBloc>().add(GetCustomerPointsEvent(customerId: customerId));
          } else {
            AppLogger.videoError('❌ User has no customerId assigned. Using UUID may cause errors.');
          }
        }
        
        // Cargar las categorías disponibles
        _loadCategories();
      }
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _videoManager.removeListener(_onVideoManagerChanged);
    _videoManager.dispose();
    _currentVideoController?.dispose();
    super.dispose();
  }
  
  // Método para cargar las categorías disponibles
  void _loadCategories() {
    final genresState = context.read<GenresBloc>().state;
    if (genresState is GenresLoaded) {
      setState(() {
        _categoryIds = genresState.genres.map((genre) => genre.id.toString()).toList();
        _categoryNames = genresState.genres.map((genre) => genre.name).toList();
        
        // Añadir "Todos" como primera categoría si no existe
        if (!_categoryNames.contains('Todos')) {
          _categoryIds.insert(0, '0');
          _categoryNames.insert(0, 'Todos');
        }
      });
    } else {
      // Si las categorías no están cargadas, solicitar cargarlas
      context.read<GenresBloc>().add(const LoadGenresEvent());
    }
  }

  void _onVideoManagerChanged() {
    if (!mounted) return;

    // Only update if the index actually changed
    if (_currentIndex != _videoManager.currentIndex) {
      Future.microtask(() {
        if (mounted && _videoManager.currentIndex != _currentIndex) {
          try {
            setState(() {
              _currentIndex = _videoManager.currentIndex;
            });

            // Synchronize PageController
            if (_pageController.hasClients && mounted) {
              _pageController.animateToPage(
                _currentIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          } catch (e) {
            AppLogger.videoError('❌ Error updating video index: $e');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current customer ID from AuthBloc
    final authState = context.read<AuthBloc>().state;
    String? customerId;
    
    if (authState is AuthAuthenticated) {
      if (authState.user.customerId != null) {
        customerId = authState.user.customerId.toString();
        AppLogger.videoInfo('🪙 Loading wallet points with customerId: $customerId (numeric ID)');
        // Load wallet data with the customer ID
        context.read<WalletBloc>().add(GetCustomerPointsEvent(customerId: customerId));
      } else {
        AppLogger.videoError('❌ User has no customerId assigned in build method. Cannot load points.');
      }
    }
    
    // Verificar si hay nuevas categorías disponibles
    final genresState = context.watch<GenresBloc>().state;
    if (genresState is GenresLoaded && _categoryIds.isEmpty) {
      _loadCategories();
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _horizontalDragStartPosition = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          _horizontalDragEndPosition = details.globalPosition.dx;
        },
        onHorizontalDragEnd: (details) {
          // Solo procesar el gesto si tenemos categorías cargadas
          if (_categoryIds.isEmpty) return;
          
          // Calcular la distancia del deslizamiento
          final dragDistance = _horizontalDragEndPosition - _horizontalDragStartPosition;
          
          // Si el deslizamiento es significativo (más de 50px)
          if (dragDistance.abs() > 50) {
            // Evitar múltiples cambios de categoría mientras se procesa uno
            if (_isSwipingCategory) return;
            _isSwipingCategory = true;
            
            // Determinar la dirección del deslizamiento
            if (dragDistance > 0) {
              // Deslizamiento hacia la derecha (categoría anterior)
              _navigateToPreviousCategory();
            } else {
              // Deslizamiento hacia la izquierda (categoría siguiente)
              _navigateToNextCategory();
            }
            
            // Restablecer el flag después de un tiempo
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isSwipingCategory = false;
                });
              }
            });
          }
        },
        child: BlocBuilder<VideosBloc, VideosState>(
          builder: (context, state) {
            if (state is VideosLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is VideosError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (state is VideosLoaded) {
              final videos = state.videos;

              return Stack(
                children: [
                  // PageView principal con videos
                  PageView.builder(
                    key: _pageViewKey,
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: videos.length,
                    onPageChanged: (index) async {
                      setState(() {
                        _currentIndex = index;
                      });

                      // Resetear flag de selección manual después de navegar
                      if (_manualSelectionActive && index >= 3) {
                        _manualSelectionActive = false;
                        AppLogger.videoInfo('🔄 Resetting manual selection flag');
                      }

                      // Lazy loading
                      if (index >= videos.length - 3 && !_manualSelectionActive) {
                        AppLogger.videoInfo(
                          '🔄 [LAZY LOADING] Loading more videos',
                        );
                        context.read<VideosBloc>().add(
                          LoadVideosPaginatedEvent(
                            page: state.currentPage + 1,
                            categoryId: state.currentCategory,
                          ),
                        );
                      }

                      // Sincronizar con VideoManager
                      await _videoManager.goToVideo(index);
                    },
                    itemBuilder: (context, index) {
                      final video = videos[index];

                      return TikTokVideoPlayer(
                        videoUrl: video.videoUrl,
                        isCurrentVideo: index == _currentIndex,
                        // ✅ CALLBACK MEJORADO: Usar VideoCompletionHandler
                        onVideoFinished: () => _handleVideoFinished(),
                        onMoreInfoPressed: () {
                          VideoInfoBottomSheet.show(context, video);
                        },
                        onControllerChanged: (controller) {
                          if (index == _currentIndex) {
                            setState(() {
                              _currentVideoController = controller;
                            });
                          }
                        },
                      );
                    },
                  ),

                  // UI Elements
                  Positioned(
                    right: 16,
                    top: MediaQuery.of(context).size.height * 0.30,
                    child: Column(
                      key: const ValueKey('action_buttons'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Widget de Exploración de Videos
                        VideoExplorerButton(
                          onVideoSelected: (video, playlist, startIndex) {
                            _handleVideoSelection(video, playlist, startIndex);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Widget de Monedas
                        Builder(
                          builder: (context) {
                            final currentVideo = _currentIndex < videos.length
                                ? videos[_currentIndex]
                                : videos.first;

                            return CoinsActionWidget(
                              key: const ValueKey('coins_widget'),
                              video: currentVideo,
                              onCoinsEarned: () {
                                // Callback opcional
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Widget de Likes
                        Builder(
                          builder: (context) {
                            final currentVideo =
                                videos.isNotEmpty && _currentIndex < videos.length
                                ? videos[_currentIndex]
                                : videos.first;

                            return LikeActionWidget(
                              key: const ValueKey('likes_widget'),
                              video: currentVideo,
                              videoManager: _videoManager,
                              onLikeToggled: () {
                                // Callback opcional
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Botón selector de estilos
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              final styles = ProgressIndicatorStyle.values;
                              final currentIndex = styles.indexOf(
                                _currentProgressStyle,
                              );
                              final nextIndex =
                                  (currentIndex + 1) % styles.length;
                              _currentProgressStyle = styles[nextIndex];
                            });
                            AppLogger.videoInfo(
                              '🎨 Cambiando estilo a: ${_currentProgressStyle.name}',
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(76),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStyleColor(),
                                border: Border.all(color: Colors.white),
                              ),
                              child: const Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStyleName(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Indicador de progreso
                  Positioned(
                    top: 40,
                    right: 16,
                    child:
                        _currentVideoController != null &&
                            _currentVideoController!.value.isInitialized
                        ? SmartVideoProgressIndicator(
                            key: ValueKey(
                              'smart_progress_indicator_${_currentProgressStyle.name}_$_currentIndex',
                            ),
                            controller: _currentVideoController,
                            size: 84,
                            strokeWidth: 5,
                            initialStyle: _currentProgressStyle,
                          )
                        : const SizedBox(width: 84, height: 84),
                  ),

                  // Botón "More Information"
                  Positioned(
                    key: const ValueKey('more_info_button'),
                    bottom: 100,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final currentVideo =
                              videos.isNotEmpty && _currentIndex < videos.length
                              ? videos[_currentIndex]
                              : null;

                          return Opacity(
                            opacity: currentVideo != null ? 1.0 : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(38),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.green, width: 2),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: currentVideo != null
                                      ? () => VideoInfoBottomSheet.show(
                                          context,
                                          currentVideo,
                                        )
                                      : null,
                                  borderRadius: BorderRadius.circular(25),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      'More Information',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  // ✅ MÉTODO PRINCIPAL: Manejar cuando termina un video
  void _handleVideoFinished() {
    AppLogger.videoInfo('🏁 Video finished callback received');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final videosState = context.read<VideosBloc>().state;
      List<Ad> videoList = [];
      if (videosState is VideosLoaded) {
        videoList = videosState.videos;
      }

      if (videoList.isNotEmpty && _currentIndex < videoList.length) {
        final currentVideo = videoList[_currentIndex];

        // ✅ USE VideoCompletionHandler to handle video completion
        VideoCompletionHandler.handleVideoCompletion(
          context,
          currentVideo, // Pasar el video completo con sus puntos específicos
          onAnimationComplete: () {
            // After animation, advance to next video
            _advanceToNextVideo(videoList, videosState);
          },
        );
      } else {
        _advanceToNextVideo(videoList, videosState);
      }
    });
  }

  // Handle manual video selection
  void _handleVideoSelection(Ad video, List<Ad> playlist, int startIndex) {
    _manualSelectionActive = true;

    // Pause current video
    if (_currentVideoController != null &&
        _currentVideoController!.value.isInitialized) {
      _currentVideoController!.pause();
    }

    // Recreate PageController
    _pageController.dispose();
    _pageController = PageController(initialPage: startIndex);

    // Actualizar VideoManager
    _videoManager.updateVideos(playlist);

    setState(() {
      _currentIndex = startIndex;
      _pageViewKey = UniqueKey();
    });

    _videoManager.goToVideo(startIndex);

    AppLogger.videoInfo(
      '🎬 Video seleccionado desde explorador: ${video.title} (índice: $startIndex)',
    );
  }
  
  // Método para mostrar el explorador de videos
  void _showVideoExplorer() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BlocProvider(
        create: (context) => di.getIt<VideoExplorerBloc>(),
        child: VideoExplorerPage(
          onVideoSelected: (video, playlist, startIndex) {
            _handleVideoSelection(video, playlist, startIndex);
          },
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // Método para navegar a la categoría anterior
  void _navigateToPreviousCategory() {
    if (_categoryIds.isEmpty) return;
    
    // En lugar de cambiar directamente, mostrar el explorador de videos
    _showVideoExplorer();
  }
  
  // Método para navegar a la siguiente categoría
  void _navigateToNextCategory() {
    if (_categoryIds.isEmpty) return;
    
    // En lugar de cambiar directamente, mostrar el explorador de videos
    _showVideoExplorer();
  }



  // Advance to next video
  void _advanceToNextVideo(List<Ad> videoList, dynamic videosState) {
    if (videoList.isNotEmpty) {
      if (_currentIndex < videoList.length - 1) {
        final nextIndex = _currentIndex + 1;
        AppLogger.videoInfo('🎬 Auto-advancing to video $nextIndex');

        setState(() {
          _currentIndex = nextIndex;
        });

        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

        _videoManager.goToVideo(nextIndex);

        // Load more videos if we're near the end
        if (nextIndex >= videoList.length - 2) {
          AppLogger.videoInfo('🔄 Near end, loading more videos preemptively');
          if (videosState is VideosLoaded) {
            context.read<VideosBloc>().add(
              LoadVideosPaginatedEvent(
                page: videosState.currentPage + 1,
                categoryId: videosState.currentCategory,
              ),
            );
          }
        }
      } else {
        // If it's the last video, load more or loop
        AppLogger.videoInfo('🔄 Reached end, trying to load more videos');

        if (videosState is VideosLoaded) {
          context.read<VideosBloc>().add(
            LoadVideosPaginatedEvent(
              page: videosState.currentPage + 1,
              categoryId: videosState.currentCategory,
            ),
          );
        }

        // Loop back to first video
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _currentIndex = 0;
            });

            _pageController.animateToPage(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );

            _videoManager.goToVideo(0);
          }
        });
      }
    }
  }

  // Get color of current style
  Color _getStyleColor() {
    switch (_currentProgressStyle) {
      case ProgressIndicatorStyle.glassmorphism:
        return Colors.red;
      case ProgressIndicatorStyle.neumorphism:
        return Colors.blue;
      case ProgressIndicatorStyle.minimal:
        return Colors.green;
      case ProgressIndicatorStyle.gaming:
        return Colors.purple;
    }
  }

  // Get abbreviated name of current style
  String _getStyleName() {
    switch (_currentProgressStyle) {
      case ProgressIndicatorStyle.glassmorphism:
        return 'GLAS';
      case ProgressIndicatorStyle.neumorphism:
        return 'NEUR';
      case ProgressIndicatorStyle.minimal:
        return 'MINI';
      case ProgressIndicatorStyle.gaming:
        return 'GAME';
    }
  }
}
