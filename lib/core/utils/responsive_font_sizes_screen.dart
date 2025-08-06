import 'dart:io';

import 'package:flutter/material.dart';

/// Clase para manejar tamaños de fuente responsivos en toda la aplicación
/// Adapta los tamaños de fuente según el tamaño de la pantalla y la configuración del dispositivo
class ResponsiveFontSizesScreen {
  /// Método principal para calcular tamaños de fuente responsivos
  /// Ajusta el tamaño según el ancho de la pantalla y la configuración de accesibilidad
  double getResponsiveFontSize(
    BuildContext context, {
    required double minSize,
    required double maxSize,
  }) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Determinar el tamaño base según el ancho de la pantalla
    final baseFontSize = screenWidth <= 360 ? minSize : maxSize;

    // Obtener el factor de escala de texto del dispositivo
    var scaledSize = MediaQuery.of(context).textScaler.scale(1);
    var fontSize = baseFontSize;

    // Limitar el factor de escala a un máximo de 1.5
    if (scaledSize > 1.5) {
      scaledSize = 1.5;

      // Aplicar el factor de escala al tamaño base de la fuente según la plataforma
      if (Platform.isAndroid) {
        fontSize = baseFontSize / 1.1;
      } else if (Platform.isIOS) {
        fontSize = baseFontSize / 1.5;
      } else {
        // Para otras plataformas (web, desktop, etc.)
        fontSize = baseFontSize / 1.1;
      }
    }

    // Limitar el tamaño dentro del rango especificado
    return fontSize;
  }

  /// Método alternativo que mantiene mejor la proporción en dispositivos con configuraciones de accesibilidad
  double getResponsiveFontSizeHold(
    BuildContext context, {
    required double minSize,
    required double maxSize,
  }) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Obtener el TextScaler del dispositivo
    final textScaler = MediaQuery.of(context).textScaler;

    // Determinar el tamaño base según el ancho de la pantalla
    final baseFontSize = screenWidth <= 360 ? minSize : maxSize;

    // Ajustar el tamaño de fuente según el textScaler
    final scaledSize = textScaler.scale(baseFontSize);

    // Esto maneja correctamente el escalado lineal y no lineal
    final adjustedFontSizeFactor = scaledSize / baseFontSize;

    // Asignar el valor final a fontSize para usarlo en el widget Text
    final fontSize = baseFontSize / adjustedFontSizeFactor;

    // Limitar el tamaño dentro del rango especificado
    return fontSize;
  }

  /// Ajusta el tamaño de un widget en función del ancho de la pantalla y el factor de escala del dispositivo
  double getResponsiveWidgetSize(
    BuildContext context, {
    required double minSize,
    required double maxSize,
  }) {
    // Obtener el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Obtener el TextScaler del dispositivo
    final textScaler = MediaQuery.of(context).textScaler;

    // Determinar el tamaño base según el ancho de la pantalla
    final baseFontSize = screenWidth <= 360 ? minSize : maxSize;

    // Ajustar el tamaño de fuente según el textScaler
    final scaledSize = textScaler.scale(baseFontSize);

    // Esto maneja correctamente el escalado lineal y no lineal
    final adjustedFontSizeFactor = scaledSize / baseFontSize;

    // Asignar el valor final a fontSize para usarlo en el widget Text
    final fontSize = baseFontSize / adjustedFontSizeFactor;

    // Limitar el tamaño dentro del rango especificado
    return fontSize;
  }

  // Tamaños predefinidos para diferentes elementos de la UI

  /// Tamaño para títulos principales (como encabezados de página)
  double headingLarge(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 28.0, maxSize: 32.0);
  }

  /// Tamaño para títulos de sección
  double headingMedium(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 24.0, maxSize: 28.0);
  }

  /// Tamaño para subtítulos
  double headingSmall(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 20.0, maxSize: 24.0);
  }

  /// Tamaño para títulos de tarjetas o secciones
  double titleLarge(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 18.0, maxSize: 22.0);
  }

  /// Tamaño para subtítulos en tarjetas o secciones
  double titleMedium(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 16.0, maxSize: 20.0);
  }

  /// Tamaño para títulos pequeños
  double titleSmall(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 18.0);
  }

  /// Tamaño para texto de cuerpo grande
  double bodyLarge(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 16.0, maxSize: 18.0);
  }

  /// Tamaño para texto de cuerpo normal
  double bodyMedium(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para texto de cuerpo pequeño
  double bodySmall(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para botones principales
  double buttonLarge(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 16.0, maxSize: 18.0);
  }

  /// Tamaño para botones normales
  double buttonMedium(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para botones pequeños
  double buttonSmall(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para etiquetas grandes
  double labelLarge(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para etiquetas medianas
  double labelMedium(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para etiquetas pequeñas
  double labelSmall(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 10.0, maxSize: 12.0);
  }

  /// Tamaño para texto en la barra de navegación
  double navBar(BuildContext context) {
    return getResponsiveFontSizeHold(context, minSize: 10.0, maxSize: 12.0);
  }

  /// Tamaño para texto en campos de formulario
  double inputText(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para texto de ayuda o pistas
  double helperText(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para mensajes de error
  double errorText(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para texto en snackbars o toasts
  double snackBarText(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para texto en diálogos - título
  double dialogTitle(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 18.0, maxSize: 20.0);
  }

  /// Tamaño para texto en diálogos - contenido
  double dialogContent(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para texto en tarjetas de conexión - título
  double connectionCardTitle(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 16.0, maxSize: 18.0);
  }

  /// Tamaño para texto en tarjetas de conexión - subtítulo
  double connectionCardSubtitle(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 14.0, maxSize: 16.0);
  }

  /// Tamaño para texto en tarjetas de conexión - detalles
  double connectionCardDetails(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 12.0, maxSize: 14.0);
  }

  /// Tamaño para texto en pantallas de onboarding - título
  double onboardingTitle(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 24.0, maxSize: 28.0);
  }

  /// Tamaño para texto en pantallas de onboarding - descripción
  double onboardingDescription(BuildContext context) {
    return getResponsiveFontSize(context, minSize: 16.0, maxSize: 18.0);
  }
}

/// Acceso global a la instancia de ResponsiveFontSizesScreen
final responsiveFontSizesScreen = ResponsiveFontSizesScreen();
