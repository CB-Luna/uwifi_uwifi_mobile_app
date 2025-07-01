# Reglas de Codificación para el Proyecto UWifi

## Colores y Opacidad

### ❌ NO usar withOpacity
```dart
// MAL - causa problemas de performance
Color(0xFF000000).withOpacity(0.5)
Colors.black.withOpacity(0.3)
```

### ✅ SÍ usar withValues o withAlpha
```dart
// BIEN - mejor performance
Color(0xFF000000).withValues(alpha: 0.5)
Colors.black.withAlpha((255 * 0.3).round())

// O usar directamente el constructor con alpha
Color(0x80000000) // Negro con 50% de opacidad
Color.fromRGBO(0, 0, 0, 0.5) // Negro con 50% de opacidad
```

## Razones para evitar withOpacity:
1. **Performance**: withOpacity puede causar problemas de renderizado
2. **Composición**: withValues es más eficiente para animaciones
3. **Claridad**: withValues es más explícito sobre qué valores se están modificando

## Alternativas recomendadas:
- `withValues(alpha: value)` para opacidad
- `withAlpha(int)` para valores enteros de alpha
- `Color.fromRGBO(r, g, b, opacity)` para construcción directa
- `Color(0xAARRGGBB)` para valores hexadecimales con alpha

## Herramientas para refactoring:
Usa el script `scripts/refactor_colors.dart` para convertir automáticamente withOpacity a withValues.
