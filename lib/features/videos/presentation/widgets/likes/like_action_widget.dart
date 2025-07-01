import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import '../../bloc/videos_bloc.dart';
import '../../bloc/videos_event.dart';
import '../../managers/tiktok_video_manager.dart';
import '../../../domain/entities/ad.dart';

/// Widget que maneja la funcionalidad de likes
class LikeActionWidget extends StatefulWidget {
  final Ad video;
  final TikTokVideoManager videoManager;
  final VoidCallback? onLikeToggled;

  const LikeActionWidget({
    required this.video, required this.videoManager, super.key,
    this.onLikeToggled,
  });

  @override
  State<LikeActionWidget> createState() => _LikeActionWidgetState();
}

class _LikeActionWidgetState extends State<LikeActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.liked;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLike,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(128), // 0.5 * 255 = 128
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.white,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Animación de like
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Lógica de like
    AppLogger.videoInfo('❤️ Like toggled for video: ${widget.video.title}');

    widget.videoManager.likeVideo(widget.video.id);
    context.read<VideosBloc>().add(LikeVideoEvent(widget.video.id));

    // Callback opcional
    widget.onLikeToggled?.call();
  }
}
