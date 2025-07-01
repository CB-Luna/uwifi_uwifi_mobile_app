import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../../injection_container.dart' as di;

class AppBootstrapper {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // Initialize dependency injection
    await di.init();

    // Register Supabase client
    di.registerSupabaseClient(Supabase.instance.client);
  }
}
