import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../domain/entities/genre_with_videos.dart';

/// Widget para filtrar videos por categorías
class CategoryFilterWidget extends StatefulWidget {
  final List<GenreWithVideos> categories;
  final GenreWithVideos? selectedCategory;
  final Function(GenreWithVideos?) onCategorySelected;

  const CategoryFilterWidget({
    required this.categories, required this.onCategorySelected, super.key,
    this.selectedCategory,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategoryTap(GenreWithVideos? category) {
    HapticFeedback.lightImpact();
    widget.onCategorySelected(category);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100, // Aumentar altura para acomodar el nuevo diseño
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.categories.length + 1, // +1 para "Todos"
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            // Opción "Todos"
            return _buildCategoryChip(
              label: 'Todos',
              isSelected: widget.selectedCategory == null,
              videoCount: widget.categories
                  .map((cat) => cat.totalVideos)
                  .fold(0, (sum, count) => sum + count),
              onTap: () => _onCategoryTap(null),
            );
          }

          final category = widget.categories[index - 1];
          final isSelected = widget.selectedCategory?.id == category.id;

          return _buildCategoryChip(
            label: category.name,
            posterImageUrl: category.posterImg, // Agregar poster image
            isSelected: isSelected,
            videoCount: category.totalVideos,
            onTap: () => _onCategoryTap(category),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected, required int videoCount, required VoidCallback onTap, String? posterImageUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 120, // Hacer botones más anchos
        height: 70,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.green.withValues(
                    alpha: 0.8,
                  ) // ✅ CAMBIADO: Verde para seleccionado
                : Colors.green.withValues(
                    alpha: 0.4,
                  ), // ✅ CAMBIADO: Verde claro para no seleccionado
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(
                      alpha: 0.4,
                    ), // ✅ CAMBIADO: Sombra verde
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo
              if (posterImageUrl != null)
                CachedNetworkImage(
                  imageUrl: posterImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withValues(alpha: 0.3),
                          Colors.grey.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white54,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withValues(
                            alpha: 0.4,
                          ), // ✅ CAMBIADO: Verde
                          Colors.green.withValues(
                            alpha: 0.2,
                          ), // ✅ CAMBIADO: Verde
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.category,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ),
                )
              else
                // Fondo para "Todos" con gradiente verde
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(
                          alpha: 0.6,
                        ), // ✅ CAMBIADO: Verde
                        Colors.green.withValues(
                          alpha: 0.3,
                        ), // ✅ CAMBIADO: Verde
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.apps, color: Colors.white, size: 28),
                  ),
                ),

              // Overlay con gradiente para mejorar legibilidad del texto
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Overlay de selección
              if (isSelected)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.2),
                        Colors.blue.withValues(alpha: 0.4),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

              // Contenido de texto
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Nombre de la categoría
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Contador de videos
                      if (videoCount > 0) ...[
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '$videoCount',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blue[700]
                                  : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
