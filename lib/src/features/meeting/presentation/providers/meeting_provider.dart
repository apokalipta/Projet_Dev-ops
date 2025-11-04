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
    return repository.getMeetings();
  }

  Future<void> refreshMeetings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref.read(meetingRepositoryProvider).getMeetings();
    });
  }

  Future<void> createMeeting(Meeting meeting) async {
    final repository = ref.read(meetingRepositoryProvider);
    final previousState = state;

    state = AsyncData([...state.value ?? [], meeting]);

    try {
      await repository.createMeeting(meeting);
    } catch (e, st) {
      state = previousState;
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
