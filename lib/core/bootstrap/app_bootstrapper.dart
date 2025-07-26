import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../injection_container.dart' as di;
import '../constants/app_constants.dart';

class AppBootstrapper {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // Crear cliente específico para el esquema media_library
    // No podemos usar el parámetro schema directamente, así que crearemos un cliente normal
    // y luego lo configuraremos para usar el esquema media_library en las consultas
    final mediaLibraryClient = SupabaseClient(
      AppConstants.supabaseUrl,
      AppConstants.supabaseAnonKey,
      postgrestOptions: const PostgrestClientOptions(schema: 'media_library'),
    );

    // Initialize dependency injection
    await di.init();

    // Register Supabase clients
    di.registerSupabaseClient(Supabase.instance.client);
    di.registerMediaLibraryClient(mediaLibraryClient);
  }
}
