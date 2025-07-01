import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enum para los diferentes estilos de indicador de progreso
enum ProgressIndicatorStyle {
  glassmorphism(
    'Glassmor',
    Icons.water_drop_outlined,
    'Efecto de vidrio translúcido',
  ),
  neumorphism('Neumor', Icons.grain, 'Estilo 3D suave y táctil'),
  minimal('Minimal', Icons.circle_outlined, 'Líneas finas y elegantes'),
  gaming('Gaming/Tech', Icons.flash_on, 'Futurista con efectos neón');

  const ProgressIndicatorStyle(this.displayName, this.icon, this.description);
  final String displayName;
  final IconData icon;
  final String description;
}

/// Widget selector de estilos para el indicador de progreso
class ProgressStyleSelector extends StatefulWidget {
  final ProgressIndicatorStyle currentStyle;
  final Function(ProgressIndicatorStyle) onStyleChanged;
  final double size;

  const ProgressStyleSelector({
    required this.currentStyle, required this.onStyleChanged, super.key,
    this.size = 50,
  });

  @override
  State<ProgressStyleSelector> createState() => _ProgressStyleSelectorState();
}

class _ProgressStyleSelectorState extends State<ProgressStyleSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _selectStyle(ProgressIndicatorStyle style) {
    widget.onStyleChanged(style);
    _toggleExpanded();

    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  Color _getStyleColor(ProgressIndicatorStyle style) {
    switch (style) {
      case ProgressIndicatorStyle.glassmorphism:
        return Colors.blue.withAlpha(179); // 0.7
      case ProgressIndicatorStyle.neumorphism:
        return Colors.grey.withAlpha(179); // 0.7
      case ProgressIndicatorStyle.minimal:
        return Colors.white.withAlpha(179); // 0.7
      case ProgressIndicatorStyle.gaming:
        return const Color(0xFF00FF41).withAlpha(179); // 0.7
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Opciones expandidas
        if (_isExpanded)
          Positioned(
            top: -(ProgressIndicatorStyle.values.length * 65.0),
            left: 0,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ProgressIndicatorStyle.values.map((style) {
                      final isSelected = style == widget.currentStyle;
                      final delay =
                          ProgressIndicatorStyle.values.indexOf(style) * 0.1;

                      return AnimatedContainer(
                        duration: Duration(
                          milliseconds: 200 + (delay * 100).round(),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () => _selectStyle(style),
                          child: Container(
                            width: widget.size + 20,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: isSelected
                                  ? _getStyleColor(style)
                                  : Colors.black.withAlpha(179), // 0.7
                              border: Border.all(
                                color: _getStyleColor(style),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getStyleColor(
                                    style,
                                  ).withAlpha(77), // 0.3
                                  blurRadius: isSelected ? 12 : 6,
                                  spreadRadius: isSelected ? 2 : 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(style.icon, color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    style.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

        // Botón principal
        GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getStyleColor(widget.currentStyle),
                  _getStyleColor(widget.currentStyle).withAlpha(77), // 0.3
                ],
              ),
              border: Border.all(
                color: Colors.white.withAlpha(77), // 0.3
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(77), // 0.3
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: _getStyleColor(
                    widget.currentStyle,
                  ).withAlpha(102), // 0.4
                  blurRadius: 15,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Icono del estilo actual
                Icon(
                  widget.currentStyle.icon,
                  color: Colors.white,
                  size: widget.size * 0.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(128), // 0.5
                      blurRadius: 4,
                    ),
                  ],
                ),

                // Indicador de expandido
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(230), // 0.9
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51), // 0.2
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.expand_less,
                        color: _getStyleColor(widget.currentStyle),
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tooltip informativo
        if (_isExpanded)
          Positioned(
            top: widget.size + 10,
            left: -20,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size + 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(204), // 0.8
                      border: Border.all(
                        color: _getStyleColor(
                          widget.currentStyle,
                        ).withAlpha(128), // 0.5
                      ),
                    ),
                    child: Text(
                      widget.currentStyle.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
