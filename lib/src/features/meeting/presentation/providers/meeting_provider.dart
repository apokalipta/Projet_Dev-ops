import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/data/repositories/meeting_repository_impl.dart';

part 'meeting_provider.g.dart';

// Provider d'état asynchrone pour la liste des réunions
// Utilise AsyncNotifier et la génération de code
@riverpod
class AsyncMeeting extends _$AsyncMeeting {
  
  // La méthode build est appelée pour initialiser l'état
  @override
  Future<List<Meeting>> build() async {
    // Garde l'état en cache même s'il n'est plus écouté
    // Gère la "Mémoire entre les pages" du document
    ref.keepAlive();
    
    // Récupère le repository
    final repository = ref.watch(meetingRepositoryProvider);
    
    // Appelle la méthode pour récupérer les données initiales
    return repository.getMeetings();
  }

  // Méthode pour rafraîchir manuellement la liste
  Future<void> refreshMeetings() async {
    // Passe l'état en chargement
    state = const AsyncValue.loading();
    // Ré-exécute la logique de 'build'
    state = await AsyncValue.guard(() {
      return ref.read(meetingRepositoryProvider).getMeetings();
    });
  }

  // Action pour créer une réunion
  Future<void> createMeeting(Meeting meeting) async {
    final repository = ref.read(meetingRepositoryProvider);
    
    // Met à jour l'état de manière optimiste (optionnel) ou après succès
    state = await AsyncValue.guard(() async {
      await repository.createMeeting(meeting);
      // Rafraîchit la liste après la création
      return repository.getMeetings();
    });
  }
  
  // Action pour supprimer une réunion
  Future<void> deleteMeeting(String id) async {
    final repository = ref.read(meetingRepositoryProvider);
    
    state = await AsyncValue.guard(() async {
      await repository.deleteMeeting(id);
      // Rafraîchit la liste après la suppression
      return repository.getMeetings();
    });
  }
}
