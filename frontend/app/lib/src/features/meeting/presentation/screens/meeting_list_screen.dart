import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meeting_app/src/features/meeting/presentation/providers/meeting_provider.dart';
import 'package:meeting_app/src/features/meeting/presentation/widgets/meeting_card.dart';

class MeetingListScreen extends ConsumerWidget {
  const MeetingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meetingsAsync = ref.watch(asyncMeetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réunions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/create-meeting');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(asyncMeetingProvider.notifier).refreshMeetings(),
        child: meetingsAsync.when(
          data: (meetings) {
            if (meetings.isEmpty) {
              return const Center(child: Text('Aucune réunion pour le moment.'));
            }
            return ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                return MeetingCard(
                  meeting: meeting,
                  onTap: () {
                    // Navigation vers les détails de la réunion
                    context.push('/meeting-details/${meeting.id}');
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmer la suppression'),
                          content: const Text('Êtes-vous sûr de vouloir supprimer cette réunion ?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Annuler'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Ferme la dialog
                              },
                            ),
                            TextButton(
                              child: const Text('Supprimer'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop(); // Ferme la dialog
                                ref.read(asyncMeetingProvider.notifier).deleteMeeting(meeting.id);
                                // Affiche une notification de succès
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('La réunion a été supprimée.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(asyncMeetingProvider.notifier).refreshMeetings(),
                  child: const Text('Réessayer'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
