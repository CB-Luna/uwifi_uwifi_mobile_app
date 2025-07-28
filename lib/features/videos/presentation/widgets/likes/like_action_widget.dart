import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwifiapp/core/utils/app_logger.dart';
import 'package:uwifiapp/injection_container.dart' as di;
import 'package:uwifiapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:uwifiapp/features/auth/presentation/bloc/auth_state.dart';
import '../../bloc/videos_bloc.dart';
import '../../bloc/videos_event.dart' as videos_events;
import '../../bloc/video_likes_bloc.dart';
import '../../bloc/video_likes_event.dart';
import '../../bloc/video_likes_state.dart';
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
  int? _customerId;
  late VideoLikesBloc _videoLikesBloc;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.video.liked;
    _videoLikesBloc = di.getIt<VideoLikesBloc>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    // Obtener el customerId del usuario autenticado
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.customerId != null) {
      _customerId = authState.user.customerId;
      
      // Verificar si el usuario ha dado like al video
      _checkLikeStatus();
    } else {
      AppLogger.videoError('❌ No se pudo obtener el customerId del usuario');
    }
  }
  
  void _checkLikeStatus() {
    if (_customerId != null) {
      _videoLikesBloc.add(CheckVideoLikeStatusEvent(
        customerId: _customerId!,
        videoId: widget.video.id,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoLikesBloc, VideoLikesState>(
      bloc: _videoLikesBloc,
      listener: (context, state) {
        if (state is VideoLikeStatus && state.videoId == widget.video.id) {
          setState(() {
            _isLiked = state.isLiked;
          });
        } else if (state is VideoLikeSuccess) {
          AppLogger.videoInfo('✅ Like registrado con éxito: ${state.response.likeId}');
        } else if (state is VideoUnlikeSuccess) {
          AppLogger.videoInfo('✅ Like eliminado con éxito');
        } else if (state is VideoLikesError) {
          AppLogger.videoError('❌ Error en operación de like: ${state.message}');
        }
      },
      child: GestureDetector(
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
      ),
    );
  }

  void _handleLike() {
    if (_customerId == null) {
      AppLogger.videoError('❌ No se puede dar like: customerId no disponible');
      return;
    }
    
    // Animación de like
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Anticipamos el cambio de estado para una mejor experiencia de usuario
    setState(() {
      _isLiked = !_isLiked;
    });

    // Lógica de like con el nuevo VideoLikesBloc
    AppLogger.videoInfo('❤️ Like toggled for video: ${widget.video.title} by customer: $_customerId');

    // Registrar en el manager de videos para compatibilidad
    widget.videoManager.likeVideo(widget.video.id);
    
    // Mantener la llamada al VideosBloc original para compatibilidad
    context.read<VideosBloc>().add(videos_events.LikeVideoEvent(widget.video.id));
    
    // Usar el nuevo VideoLikesBloc con el customerId
    if (_isLiked) {
      _videoLikesBloc.add(LikeVideoEvent(
        customerId: _customerId!,
        videoId: widget.video.id,
      ));
    } else {
      _videoLikesBloc.add(UnlikeVideoEvent(
        customerId: _customerId!,
        videoId: widget.video.id,
      ));
    }

    // Callback opcional
    widget.onLikeToggled?.call();
  }
}
