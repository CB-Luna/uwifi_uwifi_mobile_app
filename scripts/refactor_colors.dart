#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter/foundation.dart';

/// Script para refactorizar automáticamente withOpacity a withValues
/// Uso: dart scripts/refactor_colors.dart
void main(List<String> args) async {
  debugPrint('🎨 Iniciando refactoring de withOpacity a withValues...\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    debugPrint('❌ Error: Directorio lib/ no encontrado');
    exit(1);
  }

  int filesModified = 0;
  int replacements = 0;

  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final result = await refactorFile(file);
      if (result.modified) {
        filesModified++;
        replacements += result.replacements;
        debugPrint('✅ ${file.path}: ${result.replacements} reemplazos');
      }
    }
  }

  debugPrint('\n🎉 Refactoring completado!');
  debugPrint('📁 Archivos modificados: $filesModified');
  debugPrint('🔄 Total de reemplazos: $replacements');
}

class RefactorResult {
  final bool modified;
  final int replacements;

  RefactorResult(this.modified, this.replacements);
}

Future<RefactorResult> refactorFile(File file) async {
  try {
    final content = await file.readAsString();
    final originalContent = content;

    // Patrón para encontrar .withOpacity(valor)
    final withOpacityPattern = RegExp(r'\.withOpacity\(([^)]+)\)');

    String newContent = content;
    int replacements = 0;

    newContent = newContent.replaceAllMapped(withOpacityPattern, (match) {
      final opacityValue = match.group(1)!.trim();
      replacements++;
      return '.withValues(alpha: $opacityValue)';
    });

    if (newContent != originalContent) {
      await file.writeAsString(newContent);
      return RefactorResult(true, replacements);
    }

    return RefactorResult(false, 0);
  } catch (e) {
    debugPrint('❌ Error procesando ${file.path}: $e');
    return RefactorResult(false, 0);
  }
}
