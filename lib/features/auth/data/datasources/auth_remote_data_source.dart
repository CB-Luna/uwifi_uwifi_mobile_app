import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isUserLoggedIn();
  Future<void> resetPassword(String email);
  Future<UserModel?> getUserByEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar al usuario con Supabase Auth
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      final user = response.user!;

      // 2. Obtener los datos adicionales del cliente desde la tabla customer
      final customerData = await supabaseClient
          .from('customer')
          .select('customer_id, customer_afiliate_id, shared_link_id')
          .eq('auth_id', user.id)
          .single();

      AppLogger.navInfo('Customer data: $customerData'); // Log para depuración

      // 3. Crear y devolver el modelo de usuario con todos los datos
      return UserModel(
        id: user.id,
        email: user.email!,
        name: user.userMetadata?['name'] as String?,
        profileImageUrl: user.userMetadata?['avatar_url'] as String?,
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
        customerId: customerData['customer_id'] as int?,
        customerAfiliateId: customerData['customer_afiliate_id'] as int?,
        sharedLinkId: customerData['shared_link_id'] as String?,
      );
    } on AuthException catch (e) {
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      AppLogger.navInfo('Error in login: $e'); // Log para depuración
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) return null;

      // Obtener los datos adicionales del cliente desde la tabla customer
      try {
        final customerData = await supabaseClient
            .from('customer')
            .select('customer_id, customer_afiliate_id, shared_link_id')
            .eq('auth_id', user.id)
            .single();

        AppLogger.navInfo(
          'Customer data retrieved for current user: $customerData',
        );

        return UserModel(
          id: user.id,
          email: user.email!,
          name: user.userMetadata?['name'] as String?,
          profileImageUrl: user.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(user.createdAt),
          updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
          customerId: customerData['customer_id'] as int?,
          customerAfiliateId: customerData['customer_afiliate_id'] as int?,
          sharedLinkId: customerData['shared_link_id'] as String?,
        );
      } catch (customerError) {
        AppLogger.navInfo('Error retrieving customer data: $customerError');
        // Si no podemos obtener los datos del cliente, devolvemos el usuario básico
        return UserModel(
          id: user.id,
          email: user.email!,
          name: user.userMetadata?['name'] as String?,
          profileImageUrl: user.userMetadata?['avatar_url'] as String?,
          createdAt: DateTime.parse(user.createdAt),
          updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
        );
      }
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return supabaseClient.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      AppLogger.navInfo(
        'Solicitando restablecimiento de contraseña para: $email',
      );

      // URL del endpoint para restablecer contraseña
      const url =
          'https://u-n8n.virtalus.cbluna-dev.com/webhook/uwifi_customer_reset_password';

      // Realizar la solicitud HTTP POST
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      // Verificar la respuesta
      if (response.statusCode != 200) {
        AppLogger.navError('Error al restablecer contraseña: ${response.body}');
        throw Exception(
          'Error al restablecer contraseña: ${response.statusCode}',
        );
      }

      AppLogger.navInfo(
        'Solicitud de restablecimiento de contraseña enviada con éxito',
      );
    } catch (e) {
      AppLogger.navError('Error en resetPassword: $e');
      throw Exception('Error al restablecer contraseña: $e');
    }
  }
  
  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      AppLogger.authInfo('Buscando usuario por email: $email');
      
      // Intentamos iniciar sesión con el email usando la sesión actual
      // Esto es una alternativa ya que no podemos buscar directamente por email sin credenciales
      final currentSession = supabaseClient.auth.currentSession;
      
      if (currentSession != null) {
        // Si hay una sesión activa, verificamos si el email coincide con el usuario actual
        final currentUser = supabaseClient.auth.currentUser;
        
        if (currentUser != null && currentUser.email?.toLowerCase() == email.toLowerCase()) {
          // El email coincide con el usuario actual, obtenemos sus datos
          try {
            final customerData = await supabaseClient
                .from('customer')
                .select('customer_id, customer_afiliate_id, shared_link_id')
                .eq('auth_id', currentUser.id)
                .single();

            AppLogger.authInfo('Datos de cliente encontrados para email: $email');

            return UserModel(
              id: currentUser.id,
              email: currentUser.email!,
              name: currentUser.userMetadata?['name'] as String?,
              profileImageUrl: currentUser.userMetadata?['avatar_url'] as String?,
              createdAt: DateTime.parse(currentUser.createdAt),
              updatedAt: DateTime.parse(currentUser.updatedAt ?? currentUser.createdAt),
              customerId: customerData['customer_id'] as int?,
              customerAfiliateId: customerData['customer_afiliate_id'] as int?,
              sharedLinkId: customerData['shared_link_id'] as String?,
            );
          } catch (customerError) {
            AppLogger.authWarning('Error al obtener datos de cliente: $customerError');
            // Si no podemos obtener los datos del cliente, devolvemos el usuario básico
            return UserModel(
              id: currentUser.id,
              email: currentUser.email!,
              name: currentUser.userMetadata?['name'] as String?,
              profileImageUrl: currentUser.userMetadata?['avatar_url'] as String?,
              createdAt: DateTime.parse(currentUser.createdAt),
              updatedAt: DateTime.parse(currentUser.updatedAt ?? currentUser.createdAt),
            );
          }
        }
      }
      
      // Si no hay sesión o el email no coincide, intentamos buscar en la base de datos
      // Nota: Esto solo funcionará si tenemos permisos para consultar la tabla auth.users
      final userData = await supabaseClient
          .from('customer')
          .select('auth_id, customer_id, customer_afiliate_id, shared_link_id')
          .eq('email', email.toLowerCase())
          .maybeSingle();
      
      if (userData != null) {
        final authId = userData['auth_id'] as String;
        
        // Construimos un modelo de usuario con los datos disponibles
        return UserModel(
          id: authId,
          email: email,
          customerId: userData['customer_id'] as int?,
          customerAfiliateId: userData['customer_afiliate_id'] as int?,
          sharedLinkId: userData['shared_link_id'] as String?,
          // Estos campos no los tenemos disponibles sin acceso a auth.users
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      
      // Si no encontramos al usuario, devolvemos null
      AppLogger.authWarning('No se encontró usuario con email: $email');
      return null;
    } catch (e) {
      // Si hay algún error, devolvemos null
      AppLogger.authWarning('Error al buscar usuario con email: $email. Error: $e');
      return null;
    }
  }
}
