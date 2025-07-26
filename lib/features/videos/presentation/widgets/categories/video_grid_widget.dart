import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../domain/entities/ad.dart';

/// Widget de grid para mostrar videos con miniaturas - CONSOLIDADO
class VideoGridWidget extends StatelessWidget {
  final List<Ad> videos;
  final ScrollController? scrollController;
  final Function(Ad video, int index) onVideoTap;
  final bool isLoadingMore;
  final bool isRefreshing;
  final VoidCallback? onRefresh;
  final String? title; // ✅ NUEVO: Título opcional para categorías
  final bool showHeader; // ✅ NUEVO: Mostrar header o no
  final bool enableRefresh; // ✅ NUEVO: Habilitar refresh o no
  final EdgeInsets? padding; // ✅ NUEVO: Padding personalizable
  final int crossAxisCount; // ✅ NUEVO: Número de columnas personalizable

  const VideoGridWidget({
    required this.videos, required this.onVideoTap, super.key,
    this.scrollController,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.onRefresh,
    this.title,
    this.showHeader = false,
    this.enableRefresh = true,
    this.padding,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay videos, mostrar estado vacío
    if (videos.isEmpty) {
      return _buildEmptyState(context);
    }

    // Determinar el número de columnas basado en el tamaño de pantalla
    final effectiveCrossAxisCount = _getEffectiveCrossAxisCount(context);

    Widget gridContent = CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header opcional para categorías
        if (showHeader && title != null) _buildHeaderSliver(context),

        // Grid de videos
        SliverPadding(
          padding: padding ?? const EdgeInsets.fromLTRB(20, 16, 20, 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: effectiveCrossAxisCount,
              childAspectRatio: 0.7, // Aspecto optimizado para videos
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= videos.length) return null;

              final video = videos[index];
              return VideoThumbnailCard(
                video: video,
                index: index,
                onTap: () => onVideoTap(video, index),
              );
            }, childCount: videos.length),
          ),
        ),

        // Indicador de carga más videos
        if (isLoadingMore) _buildLoadingMoreSliver(),

        // Espaciado final
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );

    // Envolver con RefreshIndicator si está habilitado
    if (enableRefresh && onRefresh != null) {
      return RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          onRefresh!.call();
        },
        color: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        child: gridContent,
      );
    }

    return gridContent;
  }

  int _getEffectiveCrossAxisCount(BuildContext context) {
    if (crossAxisCount > 0) return crossAxisCount;

    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      return 3; // Tablets
    } else {
      return 2; // Teléfonos
    }
  }

  Widget _buildHeaderSliver(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${videos.length} videos disponibles',
                    style: TextStyle(
                      color: Colors.white.withAlpha(179),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.video_library,
                color: Colors.blue.shade300,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreSliver() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              SizedBox(height: 8),
              Text(
                'Cargando más videos...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.white.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay videos disponibles',
            style: TextStyle(
              color: Colors.white.withAlpha(179),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 8),
            Text(
              'en la categoría "$title"',
              style: TextStyle(
                color: Colors.white.withAlpha(128),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card individual para cada video con miniatura
class VideoThumbnailCard extends StatefulWidget {
  final Ad video;
  final int index;
  final VoidCallback onTap;

  const VideoThumbnailCard({
    required this.video, required this.index, required this.onTap, super.key,
  });

  @override
  State<VideoThumbnailCard> createState() => _VideoThumbnailCardState();
}

class _VideoThumbnailCardState extends State<VideoThumbnailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animación de entrada
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  // Método _formatDuration eliminado ya que ya no se usa

  String _generateThumbnailUrl(String videoUrl) {
    // Generar miniatura basada en la URL del video
    // Por ahora retornamos un placeholder, pero aquí podrías implementar
    // la lógica para generar thumbnails reales
    if (widget.video.thumbnailUrl != null &&
        widget.video.thumbnailUrl!.isNotEmpty) {
      return widget.video.thumbnailUrl!;
    }

    // Placeholder basado en el ID del video para consistencia
    return 'https://picsum.photos/400/600?random=${widget.video.id}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : 1.0,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen de miniatura
                      CachedNetworkImage(
                        imageUrl: _generateThumbnailUrl(widget.video.videoUrl),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[900],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.video_library_outlined,
                                color: Colors.white.withValues(alpha: 0.5),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Video ${widget.video.id}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Gradiente overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Información del video
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Título
                              Text(
                                widget.video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Metadatos
                              Row(
                                children: [
                                  // Duración
                                  // Nota: Se eliminó la visualización de duración ya que el campo durationVideo ya no existe
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Video', // Texto genérico en lugar de duración
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Icono de play
                      Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),

                      // Badge de liked si aplica
                      if (widget.video.liked)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
