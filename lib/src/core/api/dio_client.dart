import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'dio_client.g.dart';

// Provider pour l'instance Dio
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio();
  
  // URL de base de votre API (à charger depuis .env)
  dio.options.baseUrl = 'http://votre-api.domaine.com/api';
  dio.options.connectTimeout = const Duration(milliseconds: 5000); // 5s
  dio.options.receiveTimeout = const Duration(milliseconds: 3000); // 3s

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: Récupérer le jeton d'authentification (ex: depuis le stockage sécurisé)
        // final token = await ref.read(secureStorageProvider).read(key: 'auth_token');
        const token = null; // Placeholder
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Traitement global des réponses
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Gestion globale des erreurs (comme décrit dans le document)
        if (e.response?.statusCode == 401) {
          // Non autorisé
          // TODO: Déclencher la déconnexion et la redirection vers /login
          // ref.read(authNotifierProvider.notifier).logout();
        }
        // Gérer les erreurs 500
        else if (e.response?.statusCode == 500) {
          // Erreur serveur
          // TODO: Afficher une notification d'erreur générique
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
