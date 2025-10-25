import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/features/meeting/presentation/providers/meeting_provider.dart';
import 'package:meeting_app/src/features/meeting/presentation/widgets/meeting_card.dart';

class MeetingListScreen extends ConsumerWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écoute le provider d'état asynchrone
    final meetingsAsync = ref.watch(asyncMeetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réunions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Naviguer vers l'écran de création de réunion
              // ref.read(asyncMeetingProvider.notifier).createMeeting(...);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // Gère le "Pull-to-Refresh"
        onRefresh: () {
          return ref.read(asyncMeetingProvider.notifier).refreshMeetings();
        },
        // Gère les 3 états de l'AsyncValue (data, loading, error)
        child: meetingsAsync.when(
          data: (meetings) {
            if (meetings.isEmpty) {
              return const Center(child: Text('Aucune réunion pour le moment.'));
            }
            // Affiche la liste
            return ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                return MeetingCard(
                  meeting: meeting,
                  onTap: () {
                    // TODO: Naviguer vers les détails de la réunion
                    // context.go('/meetings/${meeting.id}');
                  },
                  onDelete: () {
                    // TODO: Confirmer la suppression
                    ref.read(asyncMeetingProvider.notifier).deleteMeeting(meeting.id);
                  },
                );
              },
            );
          },
          loading: () {
            // Affiche un indicateur de chargement
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, stackTrace) {
            // Affiche un message d'erreur
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(asyncMeetingProvider.notifier).refreshMeetings();
                    },
                    child: const Text('Réessayer'),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
