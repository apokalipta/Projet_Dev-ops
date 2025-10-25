import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_list_screen.dart';

part 'app_router.g.dart';

// Crée un provider Riverpod pour notre routeur
@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const MeetingListScreen();
        },
      ),
      // Exemple de route avec paramètre
      // GoRoute(
      //   path: '/meetings/:id',
      //   builder: (BuildContext context, GoRouterState state) {
      //     final meetingId = state.pathParameters['id']!;
      //     return MeetingDetailScreen(meetingId: meetingId);
      //   },
      // ),
    ],
    // TODO: Ajouter une logique de redirection pour l'authentification
    // redirect: (BuildContext context, GoRouterState state) {
    //   // Logique pour vérifier si l'utilisateur est connecté
    //   // final bool loggedIn = ...;
    //   // if (!loggedIn) return '/login';
    //   return null; // Pas de redirection
    // },
  );
}
