import 'package:flutter/material.dart';

import '../../../domain/entities/ad.dart';
import 'points_info_bottom_sheet.dart';

/// Widget que maneja la funcionalidad de puntos/monedas con animaciones de gaming
class CoinsActionWidget extends StatefulWidget {
  // Clave global para acceder al estado del widget desde fuera
  static final GlobalKey<_CoinsActionWidgetState> globalKey =
      GlobalKey<_CoinsActionWidgetState>();
  final Ad video;
  final VoidCallback? onCoinsEarned;
  final VoidCallback? onDialogOpened;
  final VoidCallback? onDialogClosed;
  final int? currentUserPoints;

  const CoinsActionWidget({
    required this.video,
    super.key,
    this.onCoinsEarned,
    this.onDialogOpened,
    this.onDialogClosed,
    this.currentUserPoints,
  });

  // Constructor con clave global
  static CoinsActionWidget withGlobalKey({
    required Ad video,
    VoidCallback? onCoinsEarned,
    VoidCallback? onDialogOpened,
    VoidCallback? onDialogClosed,
    int? currentUserPoints,
  }) {
    return CoinsActionWidget(
      key: globalKey,
      video: video,
      onCoinsEarned: onCoinsEarned,
      onDialogOpened: onDialogOpened,
      onDialogClosed: onDialogClosed,
      currentUserPoints: currentUserPoints,
    );
  }

  @override
  State<CoinsActionWidget> createState() => _CoinsActionWidgetState();
}

class _CoinsActionWidgetState extends State<CoinsActionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  // Método público para animar el botón cuando se ganan monedas
  void animateCoinsEarned() async {
    // Animación de crecimiento
    await _animationController.forward();
    await Future.delayed(const Duration(milliseconds: 1700));

    // Animación de regreso al tamaño normal
    await _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _isProcessing ? null : () => _handleCoins(context),
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: _isProcessing
                    ? LinearGradient(
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      )
                    : LinearGradient(
                        colors: [Colors.amber.shade400, Colors.orange.shade600],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isProcessing ? Colors.grey : Colors.amber)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isProcessing ? Icons.hourglass_empty : Icons.monetization_on,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCoins(BuildContext context) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Animar el botón
    await _animationController.forward();
    await _animationController.reverse();

    // Notificar que se va a abrir el diálogo para pausar el video
    widget.onDialogOpened?.call();
    
    // Mostrar el bottom sheet con la información de puntos
    await Future.delayed(const Duration(milliseconds: 100));
    if (context.mounted) {
      // Mostrar el nuevo PointsInfoBottomSheet
      await PointsInfoBottomSheet.show(context, widget.video);
      
      // Notificar que se cerró el diálogo para reanudar el video
      widget.onDialogClosed?.call();
    }

    // Restaurar el estado después de un breve retraso
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      // Callback opcional para notificar la acción
      widget.onCoinsEarned?.call();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
