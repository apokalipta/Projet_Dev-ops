import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/data/repositories/meeting_repository_impl.dart';

part 'meeting_provider.g.dart';

@riverpod
class AsyncMeeting extends _$AsyncMeeting {
  
  @override
  Future<List<Meeting>> build() async {
    ref.keepAlive();
    final repository = ref.watch(meetingRepositoryProvider);
    
    try {
      // Récupérer les réunions réelles de l'API
      final realMeetings = await repository.getMeetings();
      
      // Ajouter une réunion de démonstration avec transcription
      final demoMeeting = Meeting(
        id: 'demo-999',
        title: '🎬 Réunion de Démonstration',
        description: 'Réunion exemple avec participants et transcription complète',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        duration: 45,
        language: 'fr',
        status: MeetingStatus.completed,
        participants: [
          const Participant(
            id: 'p1',
            name: 'Alice Martin',
            email: 'alice.martin@example.com',
          ),
          const Participant(
            id: 'p2',
            name: 'Bob Dupont',
            email: 'bob.dupont@example.com',
          ),
          const Participant(
            id: 'p3',
            name: 'Claire Dubois',
            email: 'claire.dubois@example.com',
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      
      // Combiner les réunions réelles avec la démo
      return [demoMeeting, ...realMeetings];
    } catch (e) {
      // En cas d'erreur API, retourner au moins la réunion de démo
      return [
        Meeting(
          id: 'demo-999',
          title: '🎬 Réunion de Démonstration',
          description: 'Réunion exemple avec participants et transcription complète',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          duration: 45,
          language: 'fr',
          status: MeetingStatus.completed,
          participants: [
            const Participant(
              id: 'p1',
              name: 'Alice Martin',
              email: 'alice.martin@example.com',
            ),
            const Participant(
              id: 'p2',
              name: 'Bob Dupont',
              email: 'bob.dupont@example.com',
            ),
            const Participant(
              id: 'p3',
              name: 'Claire Dubois',
              email: 'claire.dubois@example.com',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
    }
  }

  Future<void> refreshMeetings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(meetingRepositoryProvider);
      try {
        final realMeetings = await repository.getMeetings();
        
        // Réunion de démonstration
        final demoMeeting = Meeting(
          id: 'demo-999',
          title: '🎬 Réunion de Démonstration',
          description: 'Réunion exemple avec participants et transcription complète',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          duration: 45,
          language: 'fr',
          status: MeetingStatus.completed,
          participants: [
            const Participant(
              id: 'p1',
              name: 'Alice Martin',
              email: 'alice.martin@example.com',
            ),
            const Participant(
              id: 'p2',
              name: 'Bob Dupont',
              email: 'bob.dupont@example.com',
            ),
            const Participant(
              id: 'p3',
              name: 'Claire Dubois',
              email: 'claire.dubois@example.com',
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        );
        
        return [demoMeeting, ...realMeetings];
      } catch (e) {
        // En cas d'erreur, retourner au moins la démo
        return [
          Meeting(
            id: 'demo-999',
            title: '🎬 Réunion de Démonstration',
            description: 'Réunion exemple avec participants et transcription complète',
            date: DateTime.now().subtract(const Duration(hours: 2)),
            duration: 45,
            language: 'fr',
            status: MeetingStatus.completed,
            participants: [
              const Participant(
                id: 'p1',
                name: 'Alice Martin',
                email: 'alice.martin@example.com',
              ),
              const Participant(
                id: 'p2',
                name: 'Bob Dupont',
                email: 'bob.dupont@example.com',
              ),
              const Participant(
                id: 'p3',
                name: 'Claire Dubois',
                email: 'claire.dubois@example.com',
              ),
            ],
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ];
      }
    });
  }

  Future<Meeting> createMeeting(Meeting meeting) async {
    final repository = ref.read(meetingRepositoryProvider);
    final previousState = state;

    // Mise à jour optimiste avec la réunion locale
    state = AsyncData([...state.value ?? [], meeting]);

    try {
      // Créer sur le backend et récupérer la réunion avec l'ID du backend
      final createdMeeting = await repository.createMeeting(meeting);
      
      // Mettre à jour avec la réunion du backend
      state = AsyncData([
        ...state.value?.where((m) => m.id != meeting.id).toList() ?? [],
        createdMeeting,
      ]);
      
      return createdMeeting;
    } catch (e, st) {
      state = previousState;
      rethrow;
    }
  }
  
  // Action pour supprimer une réunion avec mise à jour optimiste
  Future<void> deleteMeeting(String id) async {
    final repository = ref.read(meetingRepositoryProvider);
    
    // Sauvegarde l'état précédent au cas où la mise à jour échoue
    final previousState = state;

    // Met à jour l'état de manière optimiste en retirant l'élément
    state = AsyncData(
      state.value?.where((m) => m.id != id).toList() ?? [],
    );

    // Tente de supprimer la réunion dans le repository
    try {
      await repository.deleteMeeting(id);
    } catch (e) {
      // En cas d'erreur, annule la mise à jour optimiste
      state = previousState;
      // On pourrait vouloir afficher une notification d'erreur ici
    }
  }
}
