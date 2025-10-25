import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/features/meeting/data/datasources/meeting_mock_datasource.dart';
// import 'package:meeting_app/src/core/database/app_database.dart'; // Pour le cache local
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/domain/repositories/meeting_repository.dart';

part 'meeting_repository_impl.g.dart';

// Implémentation concrète du Repository
// Fait le lien entre les sources de données (remote/local) et le domaine
class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingMockDataSource mockDataSource;
  // final AppDatabase localDataSource; // Pour le cache

  MeetingRepositoryImpl(this.mockDataSource);

  @override
  Future<List<Meeting>> getMeetings() async {
    try {
      // 1. Récupérer depuis le mock datasource
      final meetingModels = await mockDataSource.fetchMeetings();
      
      // 2. Convertir les Modèles (DTOs) en Entités de domaine
      final meetings = meetingModels.map((model) => model.toEntity()).toList();
      
      // 3. TODO: Mettre en cache les résultats dans Drift (la base locale)
      
      return meetings;
    } catch (e) {
      // 4. TODO: En cas d'échec, tenter de lire depuis le cache Drift
      rethrow; // Pour l'instant, on propage l'erreur
    }
  }

  @override
  Future<void> createMeeting(Meeting meeting) async {
    // TODO: Convertir l'Entité en Modèle ou Map pour l'envoyer à l'API
    // final meetingData = ...
    // await remoteDataSource.createMeeting(meetingData);
    //
    // Ne pas implémenter pour cet exemple
  }

  // ... implémenter les autres méthodes (getById, update, delete)
  
  @override
  Future<Meeting> getMeetingById(String id) {
    throw UnimplementedError();
  }
  
  @override
  Future<void> updateMeeting(Meeting meeting) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMeeting(String id) {
    throw UnimplementedError();
  }
}

// Provider Riverpod pour injecter l'implémentation du Repository
// Il expose l'interface (MeetingRepository) et non l'implémentation
@riverpod
MeetingRepository meetingRepository(Ref ref) {
  final mockDataSource = ref.watch(meetingMockDataSourceProvider);
  return MeetingRepositoryImpl(mockDataSource);
}
