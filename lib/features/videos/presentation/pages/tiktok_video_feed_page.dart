import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/bloc/wallet_bloc.dart';
import '../../../profile/presentation/bloc/wallet_event.dart';
import '../../../profile/presentation/bloc/wallet_state.dart';
import '../../domain/entities/ad.dart';
import '../bloc/genres_bloc.dart';
import '../bloc/genres_event.dart';
import '../bloc/genres_state.dart';
import '../bloc/video_explorer_bloc.dart';
import '../bloc/video_likes_bloc.dart';
import '../bloc/videos_bloc.dart';
import '../bloc/videos_event.dart';
import '../bloc/videos_state.dart';
import '../managers/tiktok_video_manager.dart';
import '../widgets/categories/video_explorer_button.dart';
import '../widgets/categories/video_explorer_page.dart';
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

  // Índice de la categoría actual (0 = Todos, 1 = primera categoría, etc.)
  int _currentCategoryIndex = 0;

  // Animación para el cambio de categoría
  bool _isAnimatingCategoryChange = false;

  // Modo aleatorio activado por defecto
  final bool _isRandomMode = false;

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
        AppLogger.videoInfo(
          '🎲 Iniciando carga de videos - Modo aleatorio: ${_isRandomMode ? "ACTIVADO" : "DESACTIVADO"}',
        );

        if (_isRandomMode) {
          // Cargar videos en modo aleatorio
          AppLogger.videoInfo(
            '🎲 Cargando videos aleatorios (categoryId: 0, limit: 20)',
          );
          context.read<VideosBloc>().add(
            const LoadRandomVideosEvent(
              categoryId: 0, // Categoría 0 = Todos
              limit: 20,
            ),
          );
        } else {
          // Cargar videos ordenados por fecha (modo normal)
          AppLogger.videoInfo(
            '📅 Cargando videos ordenados por fecha (categoryId: 0)',
          );
          context.read<VideosBloc>().add(
            const LoadVideosPaginatedEvent(
              categoryId: 0, // Categoría 0 = Todos
            ),
          );
        }

        // Get customer ID and load wallet data
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          if (authState.user.customerId != null) {
            final customerId = authState.user.customerId.toString();
            AppLogger.videoInfo(
              '🪙 Loading wallet points with customerId: $customerId (numeric ID)',
            );
            context.read<WalletBloc>().add(
              GetCustomerPointsEvent(customerId: customerId),
            );
          } else {
            AppLogger.videoError(
              '❌ User has no customerId assigned. Using UUID may cause errors.',
            );
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
        _categoryIds = genresState.genres
            .map((genre) => genre.id.toString())
            .toList();
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
        AppLogger.videoInfo(
          '🪙 Loading wallet points with customerId: $customerId (numeric ID)',
        );
        // Load wallet data with the customer ID
        context.read<WalletBloc>().add(
          GetCustomerPointsEvent(customerId: customerId),
        );
      } else {
        AppLogger.videoError(
          '❌ User has no customerId assigned in build method. Cannot load points.',
        );
      }
    }

    // Verificar si hay nuevas categorías disponibles
    final genresState = context.watch<GenresBloc>().state;
    if (genresState is GenresLoaded && _categoryIds.isEmpty) {
      _loadCategories();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocProvider<VideoLikesBloc>(
        create: (context) => di.getIt<VideoLikesBloc>(),
        child: GestureDetector(
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
            final dragDistance =
                _horizontalDragEndPosition - _horizontalDragStartPosition;

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.withValues(alpha: 0.8),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error to load videos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Botón para reintentar
                      ElevatedButton.icon(
                        onPressed: () {
                          // Reintentar cargar videos de la categoría actual
                          final categoryId =
                              _categoryIds.isNotEmpty &&
                                  _currentCategoryIndex < _categoryIds.length
                              ? int.tryParse(
                                      _categoryIds[_currentCategoryIndex],
                                    ) ??
                                    0
                              : 0;

                          context.read<VideosBloc>().add(
                            LoadVideosPaginatedEvent(categoryId: categoryId),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                      // Botón para cambiar de categoría
                      if (_categoryIds.length > 1)
                        TextButton(
                          onPressed: () {
                            // Navegar a la siguiente categoría
                            _navigateToNextCategory();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white70,
                          ),
                          child: const Text('Probar otra categoría'),
                        ),
                    ],
                  ),
                );
              }

              if (state is VideosLoaded) {
                final videos = state.videos;

                return Stack(
                  children: [
                    // Barra superior con indicador de categoría y botón de explorar
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Indicador de flecha izquierda para deslizamiento
                          if (_categoryNames.length > 1 &&
                              _currentCategoryIndex > 0)
                            AnimatedOpacity(
                              opacity: _isAnimatingCategoryChange ? 0.0 : 0.6,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ),
                            ),

                          // Indicador de categoría actual con animación
                          if (_categoryNames.isNotEmpty &&
                              _currentCategoryIndex < _categoryNames.length)
                            AnimatedOpacity(
                              opacity: _isAnimatingCategoryChange ? 0.7 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: _isAnimatingCategoryChange
                                      ? Border.all(
                                          color: Colors.white24,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Indicador de carga durante el cambio de categoría
                                    if (_isAnimatingCategoryChange)
                                      Container(
                                        width: 16,
                                        height: 16,
                                        margin: const EdgeInsets.only(right: 8),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white70,
                                              ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.category,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _categoryNames[_currentCategoryIndex],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Mostrar contador de categorías si hay más de una
                                    if (_categoryNames.length > 1)
                                      Text(
                                        ' (${_currentCategoryIndex + 1}/${_categoryNames.length})',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                          // Indicador de flecha derecha para deslizamiento
                          if (_categoryNames.length > 1 &&
                              _currentCategoryIndex < _categoryNames.length - 1)
                            AnimatedOpacity(
                              opacity: _isAnimatingCategoryChange ? 0.0 : 0.6,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                margin: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white70,
                                  size: 16,
                                ),
                              ),
                            ),

                          // Botón de explorar
                          GestureDetector(
                            onTap: _showVideoExplorer,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                          AppLogger.videoInfo(
                            '🔄 Resetting manual selection flag',
                          );
                        }

                        // Lazy loading
                        if (index >= videos.length - 3 &&
                            !_manualSelectionActive) {
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
                            _pauseCurrentVideo();
                            VideoInfoBottomSheet.show(context, video).then((_) {
                              _resumeCurrentVideo();
                            });
                          },
                          onControllerChanged: (controller) {
                            if (index == _currentIndex) {
                              // Actualizar el controlador sin setState para evitar errores durante el build
                              _currentVideoController = controller;

                              // Programar el setState para después del ciclo de build actual
                              Future.microtask(() {
                                if (mounted) {
                                  setState(() {
                                    // El estado ya fue actualizado, esto solo notifica a Flutter
                                  });
                                }
                              });
                            }
                          },
                        );
                      },
                    ),

                    // UI Elements
                    Positioned(
                      right: 16,
                      top: MediaQuery.of(context).size.height * 0.2,
                      child: Column(
                        key: const ValueKey('action_buttons'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botón "More Information"
                          Builder(
                            builder: (context) {
                              final currentVideo =
                                  videos.isNotEmpty &&
                                      _currentIndex < videos.length
                                  ? videos[_currentIndex]
                                  : null;

                              // Crear un contenedor circular con el efecto shimmer
                              return ClipOval(
                                child: Shimmer(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(128),
                                      shape: BoxShape.circle,
                                    ),
                                    child: InkWell(
                                      onTap: currentVideo != null
                                          ? () => VideoInfoBottomSheet.show(
                                              context,
                                              currentVideo,
                                            )
                                          : null,
                                      borderRadius: BorderRadius.circular(25),
                                      child: const Icon(
                                        Icons.info,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Widget de Exploración de Videos
                          VideoExplorerButton(
                            onVideoSelected: (video, playlist, startIndex) {
                              _handleVideoSelection(
                                video,
                                playlist,
                                startIndex,
                              );
                            },
                            onExplorerOpened: () {
                              _pauseCurrentVideo();
                            },
                            onExplorerClosed: () {
                              _resumeCurrentVideo();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Widget de Monedas
                          Builder(
                            builder: (context) {
                              final currentVideo = _currentIndex < videos.length
                                  ? videos[_currentIndex]
                                  : videos.first;

                              // Usar el constructor con clave global para poder acceder al estado desde VideoCompletionHandler
                              return CoinsActionWidget.withGlobalKey(
                                video: currentVideo,
                                onDialogOpened: () {
                                  _pauseCurrentVideo();
                                },
                                onDialogClosed: () {
                                  _resumeCurrentVideo();
                                },
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
                                  videos.isNotEmpty &&
                                      _currentIndex < videos.length
                                  ? videos[_currentIndex]
                                  : videos.first;

                              // Obtener la lista de videos con like desde el WalletBloc
                              List<String>? likedVideos;
                              final walletState = context
                                  .watch<WalletBloc>()
                                  .state;
                              if (walletState is WalletLoaded &&
                                  walletState.customerPoints != null) {
                                likedVideos =
                                    walletState.customerPoints!.adsLiked;
                                AppLogger.videoInfo(
                                  '📊 Videos con like obtenidos: ${likedVideos.length}',
                                );
                              }

                              return LikeActionWidget(
                                key: const ValueKey('likes_widget'),
                                video: currentVideo,
                                videoManager: _videoManager,
                                likedVideos: likedVideos,
                                onLikeToggled: () {
                                  // Refrescar los puntos del cliente para actualizar la lista de videos con like
                                  final authState = context
                                      .read<AuthBloc>()
                                      .state;
                                  if (authState is AuthAuthenticated &&
                                      authState.user.customerId != null) {
                                    final customerId = authState.user.customerId
                                        .toString();
                                    final customerAfiliateId = authState
                                        .user
                                        .customerAfiliateId
                                        ?.toString();
                                    context.read<WalletBloc>().add(
                                      GetCustomerPointsEvent(
                                        customerId: customerId,
                                        customerAfiliateId: customerAfiliateId,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          // Espacio adicional al final de la columna de botones
                          const SizedBox(height: 16),
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
                                'smart_progress_indicator_minimal_$_currentIndex',
                              ),
                              controller: _currentVideoController,
                              size: 40,
                              strokeWidth: 5,
                              initialStyle: ProgressIndicatorStyle.minimal,
                            )
                          : const SizedBox(width: 84, height: 84),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO PRINCIPAL: Manejar cuando termina un video
  void _handleVideoFinished() {
    AppLogger.videoInfo(
      '🏁 Video finished callback received - Index: $_currentIndex',
    );

    // Log para depurar estado inicial
    AppLogger.videoInfo(
      '📍 DIAGNÓSTICO: Estado antes de manejar video finalizado:',
    );
    AppLogger.videoInfo('📍 - Video actual índice: $_currentIndex');
    AppLogger.videoInfo('📍 - Widget montado: ${mounted ? "Sí" : "No"}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        AppLogger.videoError('❌ Widget no está montado en postFrameCallback');
        return;
      }

      final videosState = context.read<VideosBloc>().state;
      List<Ad> videoList = [];
      if (videosState is VideosLoaded) {
        videoList = videosState.videos;
        AppLogger.videoInfo('📍 Videos cargados: ${videoList.length}');
      } else {
        AppLogger.videoError(
          '❌ Estado de videos no es VideosLoaded: ${videosState.runtimeType}',
        );
      }

      if (videoList.isNotEmpty && _currentIndex < videoList.length) {
        final currentVideo = videoList[_currentIndex];
        AppLogger.videoInfo(
          '🎞️ Procesando finalización de video: "${currentVideo.title}" (ID: ${currentVideo.id})',
        );

        // ✅ USE VideoCompletionHandler to handle video completion
        // Pero NO avanzar automáticamente al siguiente video
        AppLogger.videoInfo(
          '📍 Llamando a VideoCompletionHandler.handleVideoCompletion',
        );
        VideoCompletionHandler.handleVideoCompletion(
          context,
          currentVideo, // Pasar el video completo con sus puntos específicos
          onAnimationComplete: () {
            AppLogger.videoInfo('🌟 onAnimationComplete callback ejecutado');
            // No avanzar automáticamente al siguiente video
            // El usuario debe hacer swipe manualmente para continuar
            AppLogger.videoInfo(
              '🛑 Video terminado. Esperando interacción del usuario para continuar',
            );

            // Pausar el video actual para indicar visualmente que ha terminado
            if (_currentVideoController != null &&
                _currentVideoController!.value.isPlaying) {
              _currentVideoController!.pause();
            }
          },
          customPoints: currentVideo.metadata?.points,
        );
      }
      // Eliminamos el else que llamaba a _advanceToNextVideo
      // para que nunca avance automáticamente
    });
  }

  // Handle manual video selection
  void _handleVideoSelection(Ad video, List<Ad> playlist, int startIndex) {
    _manualSelectionActive = true;

    AppLogger.videoInfo(
      '🎬 Iniciando selección de video: ${video.title} (ID: ${video.id})',
    );

    // Paso 1: Pausar y limpiar el video actual
    if (_currentVideoController != null) {
      try {
        AppLogger.videoInfo('⏸️ Pausando video actual');
        if (_currentVideoController!.value.isInitialized) {
          _currentVideoController!.pause();
        }
      } catch (e) {
        AppLogger.videoError('❌ Error al pausar video actual: $e');
      }
    }

    // Paso 2: Verificar que el índice corresponda al video correcto
    int verifiedIndex = startIndex;
    if (startIndex < playlist.length) {
      if (playlist[startIndex].id != video.id) {
        // El índice no corresponde al video seleccionado, buscar el índice correcto
        final correctIndex = playlist.indexWhere((v) => v.id == video.id);
        if (correctIndex >= 0) {
          verifiedIndex = correctIndex;
          AppLogger.videoInfo(
            '⚠️ Corrigiendo índice: $startIndex → $verifiedIndex para video ID: ${video.id}',
          );
        }
      }
    }

    // Paso 3: Limpiar el VideoManager antes de actualizar
    AppLogger.videoInfo('🧹 Limpiando VideoManager');
    _videoManager.removeListener(_onVideoManagerChanged);
    _videoManager.dispose();
    _videoManager = TikTokVideoManager();
    _videoManager.addListener(_onVideoManagerChanged);

    // Paso 4: Recrear PageController
    AppLogger.videoInfo('🔄 Recreando PageController');
    _pageController.dispose();
    _pageController = PageController(initialPage: verifiedIndex);

    // Paso 5: Actualizar VideoManager con la nueva lista
    AppLogger.videoInfo('📋 Actualizando lista de videos en VideoManager');
    _videoManager.updateVideos(playlist);

    // Paso 6: Actualizar estado y forzar reconstrucción del PageView
    setState(() {
      _currentIndex = verifiedIndex;
      _pageViewKey = UniqueKey();
      _currentVideoController =
          null; // Limpiar referencia al controlador anterior
    });

    // Paso 7: Navegar al video seleccionado
    AppLogger.videoInfo(
      '▶️ Navegando al video seleccionado (índice: $verifiedIndex)',
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _videoManager.goToVideo(verifiedIndex);
      }
    });

    AppLogger.videoInfo(
      '✅ Video seleccionado desde explorador: ${video.title} (índice: $verifiedIndex, ID: ${video.id})',
    );
  }

  // Este método fue eliminado para corregir errores de lint

  // Método para pausar el video actual
  void _pauseCurrentVideo() {
    if (_currentVideoController != null &&
        _currentVideoController!.value.isInitialized) {
      try {
        if (_currentVideoController!.value.isPlaying) {
          AppLogger.videoInfo(
            '⏸️ Pausando video actual por interacción con UI',
          );
          _currentVideoController!.pause();
        }
      } catch (e) {
        AppLogger.videoError('❌ Error al pausar video: $e');
      }
    }
  }

  // Método para reanudar el video actual
  void _resumeCurrentVideo() {
    if (_currentVideoController != null &&
        _currentVideoController!.value.isInitialized) {
      try {
        if (!_currentVideoController!.value.isPlaying) {
          AppLogger.videoInfo(
            '▶️ Reanudando video después de interacción con UI',
          );
          _currentVideoController!.play();
        }
      } catch (e) {
        AppLogger.videoError('❌ Error al reanudar video: $e');
      }
    }
  }

  // Método para mostrar el explorador de videos (usado en el menú de opciones)
  void _showVideoExplorer() {
    _pauseCurrentVideo();
    HapticFeedback.mediumImpact();

    // Mostrar modal con explorador de videos por categoría
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

    // Calcular el índice anterior, con ciclo circular
    final previousIndex = (_currentCategoryIndex - 1 < 0)
        ? _categoryIds.length - 1
        : _currentCategoryIndex - 1;

    _changeCategory(previousIndex);
  }

  // Método para navegar a la siguiente categoría
  void _navigateToNextCategory() {
    if (_categoryIds.isEmpty) return;

    // Calcular el índice siguiente, con ciclo circular
    final nextIndex = (_currentCategoryIndex + 1 >= _categoryIds.length)
        ? 0
        : _currentCategoryIndex + 1;

    _changeCategory(nextIndex);
  }

  // Método para cambiar de categoría
  void _changeCategory(int newIndex) {
    // Evitar cambios si ya estamos en esa categoría
    if (_currentCategoryIndex == newIndex) return;

    // Aplicar vibración sutil para feedback táctil
    HapticFeedback.lightImpact();

    setState(() {
      _currentCategoryIndex = newIndex;
      _isAnimatingCategoryChange = true;
    });

    // Convertir el categoryId a int
    final categoryIdStr = _categoryIds[newIndex];
    final categoryId = int.tryParse(categoryIdStr) ?? 0;

    AppLogger.videoInfo(
      '🔄 Cambiando a categoría: ${_categoryNames[newIndex]} (ID: $categoryId)',
    );

    // Mostrar indicador de carga animado
    _showCategoryChangeIndicator(
      newIndex > _currentCategoryIndex ? 'right' : 'left',
    );

    // Cargar videos de la categoría seleccionada según el modo activo
    AppLogger.videoInfo(
      '🔄 Cambiando categoría en modo: ${_isRandomMode ? "ALEATORIO" : "NORMAL"} (ID: $categoryId)',
    );

    if (_isRandomMode) {
      // Cargar videos aleatorios de la categoría seleccionada
      AppLogger.videoInfo(
        '🎲 Cargando videos aleatorios para categoría $categoryId',
      );
      context.read<VideosBloc>().add(
        LoadRandomVideosEvent(categoryId: categoryId, limit: 20),
      );
    } else {
      // Cargar videos ordenados por fecha de la categoría seleccionada
      AppLogger.videoInfo(
        '📅 Cargando videos ordenados por fecha para categoría $categoryId',
      );
      context.read<VideosBloc>().add(
        LoadVideosPaginatedEvent(categoryId: categoryId),
      );
    }

    // Esperar a que se carguen los videos y luego navegar al primer video
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isAnimatingCategoryChange = false;
        });
        // Usar animación para cambiar de página
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // Mostrar indicador animado de cambio de categoría
  void _showCategoryChangeIndicator(String direction) {
    // Crear un overlay para mostrar una animación de transición
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  direction == 'left'
                      ? Icons.arrow_back_ios_rounded
                      : Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  _categoryNames[_currentCategoryIndex],
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Mostrar el overlay
    overlayState.insert(entry);

    // Remover después de un tiempo
    Future.delayed(const Duration(milliseconds: 500), () {
      entry?.remove();
    });
  }
}
