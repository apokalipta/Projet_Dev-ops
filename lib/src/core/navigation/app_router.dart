import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/core/navigation/shell_screen.dart';
import 'package:meeting_app/src/features/home/presentation/screens/home_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/create_meeting_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_list_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_details_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_playback_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_transcript_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/meeting_recording_screen.dart';
import 'package:meeting_app/src/features/meeting/presentation/screens/define_participants_screen.dart';
import 'package:meeting_app/src/features/settings/presentation/screens/settings_screen.dart';

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
          return const ShellScreen(
            currentIndex: 0,
            child: HomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/meetings',
        builder: (BuildContext context, GoRouterState state) {
          return const ShellScreen(
            currentIndex: 1,
            child: MeetingListScreen(),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const ShellScreen(
            currentIndex: 2,
            child: SettingsScreen(),
          );
        },
      ),
      GoRoute(
        path: '/create-meeting',
        builder: (BuildContext context, GoRouterState state) {
          return const CreateMeetingScreen();
        },
      ),
      // Détails d'une réunion
      GoRoute(
        path: '/meeting-details/:id',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['id']!;
          return MeetingDetailsScreen(meetingId: meetingId);
        },
      ),
      // Lecture d'une réunion avec player audio
      GoRoute(
        path: '/meeting-playback/:id',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['id']!;
          return MeetingPlaybackScreen(meetingId: meetingId);
        },
      ),
      // Transcription d'une réunion
      GoRoute(
        path: '/meeting-transcript/:id',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['id']!;
          return MeetingTranscriptScreen(meetingId: meetingId);
        },
      ),
      // Définition des participants avant l'enregistrement
      GoRoute(
        path: '/define-participants/:id',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['id']!;
          final meetingTitle = state.uri.queryParameters['title'] ?? 'Réunion';
          final participantCount = int.tryParse(state.uri.queryParameters['count'] ?? '1') ?? 1;
          return DefineParticipantsScreen(
            meetingId: meetingId,
            meetingTitle: meetingTitle,
            participantCount: participantCount,
          );
        },
      ),
      // Enregistrement d'une réunion en direct
      GoRoute(
        path: '/meeting-recording/:id',
        builder: (BuildContext context, GoRouterState state) {
          final meetingId = state.pathParameters['id']!;
          final meetingTitle = state.uri.queryParameters['title'] ?? 'Réunion';
          return MeetingRecordingScreen(
            meetingId: meetingId,
            meetingTitle: meetingTitle,
          );
        },
      ),
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
