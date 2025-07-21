import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

class ConnectionQualityWidget extends StatefulWidget {
  const ConnectionQualityWidget({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.iconColor,
    required this.activeColor,
    required this.averageColor,
    required this.inactiveColor,
    required this.iconSize,
    required this.dotSize,
    this.width,
    this.height,
    this.textColor,
    super.key,
  });

  final double? width;
  final double? height;
  final double downloadSpeed;
  final double uploadSpeed;
  final Color iconColor;
  final Color activeColor;
  final Color averageColor;
  final Color inactiveColor;
  final double iconSize;
  final double dotSize;
  final Color? textColor; // Nuevo parámetro opcional

  @override
  State<ConnectionQualityWidget> createState() =>
      _ConnectionQualityWidgetState();
}

class _ConnectionQualityWidgetState extends State<ConnectionQualityWidget> {
  // --- LÓGICA DE CALIFICACIÓN ---
  Map<String, int> _getRatings() {
    final ratings = <String, int>{};

    // 1. Browsing (Navegación)
    if (widget.downloadSpeed > 20) {
      ratings['Browsing'] = 5;
    } else if (widget.downloadSpeed > 10) {
      ratings['Browsing'] = 4;
    } else if (widget.downloadSpeed > 5) {
      ratings['Browsing'] = 3;
    } else if (widget.downloadSpeed > 2) {
      ratings['Browsing'] = 2;
    } else if (widget.downloadSpeed > 1) {
      ratings['Browsing'] = 1;
    } else {
      ratings['Browsing'] = 0;
    }

    // 2. Gaming
    final gamingSpeed = widget.downloadSpeed < widget.uploadSpeed
        ? widget.downloadSpeed
        : widget.uploadSpeed;
    if (gamingSpeed > 25) {
      ratings['Gaming'] = 5;
    } else if (gamingSpeed > 15) {
      ratings['Gaming'] = 4;
    } else if (gamingSpeed > 8) {
      ratings['Gaming'] = 3;
    } else if (gamingSpeed > 4) {
      ratings['Gaming'] = 2;
    } else if (gamingSpeed > 2) {
      ratings['Gaming'] = 1;
    } else {
      ratings['Gaming'] = 0;
    }

    // 3. Streaming
    if (widget.downloadSpeed > 30) {
      ratings['Streaming'] = 5; // 4K
    } else if (widget.downloadSpeed > 15) {
      ratings['Streaming'] = 4; // 1080p
    } else if (widget.downloadSpeed > 8) {
      ratings['Streaming'] = 3; // 720p
    } else if (widget.downloadSpeed > 3) {
      ratings['Streaming'] = 2; // SD
    } else if (widget.downloadSpeed > 1.5) {
      ratings['Streaming'] = 1; // Baja calidad
    } else {
      ratings['Streaming'] = 0;
    }

    // 4. Video Call (Videollamada)
    if (widget.uploadSpeed > 10 && widget.downloadSpeed > 10) {
      ratings['Video Call'] = 5;
    } else if (widget.uploadSpeed > 5 && widget.downloadSpeed > 5) {
      ratings['Video Call'] = 4;
    } else if (widget.uploadSpeed > 3 && widget.downloadSpeed > 3) {
      ratings['Video Call'] = 3;
    } else if (widget.uploadSpeed > 1.5 && widget.downloadSpeed > 1.5) {
      ratings['Video Call'] = 2;
    } else if (widget.uploadSpeed > 0.8 && widget.downloadSpeed > 0.8) {
      ratings['Video Call'] = 1;
    } else {
      ratings['Video Call'] = 0;
    }

    return ratings;
  }

  // Widget para construir un solo ítem (icono + título + puntos)
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required int rating,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: widget.iconColor, size: widget.iconSize),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color:
                widget.textColor ??
                widget
                    .iconColor, // Usa textColor o el color del icono como fallback
            fontSize: 12, // Puedes ajustar este tamaño
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6), // Espacio entre el título y los puntos
        _buildRatingDots(rating),
      ],
    );
  }

  // Widget para construir los 5 puntos de calificación
  Widget _buildRatingDots(int rating) {
    Color currentActiveColor = widget.activeColor;
    if (rating <= 2) {
      currentActiveColor = widget.averageColor;
    } else if (rating <= 3) {
      currentActiveColor = widget.averageColor;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centrar los puntos
      children: List.generate(5, (index) {
        return Container(
          width: widget.dotSize,
          height: widget.dotSize,
          margin: EdgeInsets.symmetric(horizontal: widget.dotSize / 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < rating ? currentActiveColor : widget.inactiveColor,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratings = _getRatings();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildActivityItem(
              icon: Icons.public_outlined,
              title: "Browsing",
              rating: ratings['Browsing'] ?? 0,
            ),
          ),
          Expanded(
            child: _buildActivityItem(
              icon: Icons.sports_esports_outlined,
              title: "Gaming",
              rating: ratings['Gaming'] ?? 0,
            ),
          ),
          Expanded(
            child: _buildActivityItem(
              icon: Icons.personal_video_outlined,
              title: "Streaming",
              rating: ratings['Streaming'] ?? 0,
            ),
          ),
          Expanded(
            child: _buildActivityItem(
              icon: Icons.video_call_outlined,
              title: "Video Call",
              rating: ratings['Video Call'] ?? 0,
            ),
          ),
        ],
      ),
    );
  }
}

// End custom widget code
