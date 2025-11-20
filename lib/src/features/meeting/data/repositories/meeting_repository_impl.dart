import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/domain/repositories/meeting_repository.dart';
import 'package:meeting_app/src/features/meeting/data/datasources/meeting_remote_datasource.dart';
// import 'package:meeting_app/src/core/database/app_database.dart'; // Pour le cache local

part 'meeting_repository_impl.g.dart';

// Implémentation concrète du Repository
// Fait le lien entre les sources de données (remote/local) et le domaine
class MeetingRepositoryImpl implements MeetingRepository {
  final MeetingRemoteDataSource remoteDataSource;
  // final AppDatabase localDataSource; // Pour le cache

  MeetingRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Meeting>> getMeetings() async {
    try {
      // 1. Récupérer depuis le backend
      final meetingModels = await remoteDataSource.fetchMeetings();
      
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
  Future<Meeting> createMeeting(Meeting meeting) async {
    try {
      // Convertir l'Entité en Map pour l'API backend
      final meetingData = {
        'title': meeting.title,
        'description': meeting.description ?? '',
        'date': meeting.date.toIso8601String(),
        'previsual_duration': meeting.duration ?? 60,
        'nb_participants': meeting.participants.length,
        'language': meeting.language ?? 'fr',
        'status': _statusToString(meeting.status),
      };

      // Créer la réunion sur le backend
      final createdMeetingModel = await remoteDataSource.createMeeting(meetingData);
      
      // Retourner la réunion avec l'ID généré par le backend
      return createdMeetingModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  String _statusToString(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.scheduled:
        return 'SCHEDULED';
      case MeetingStatus.inProgress:
        return 'IN_PROGRESS';
      case MeetingStatus.completed:
        return 'COMPLETED';
      case MeetingStatus.transcribed:
        return 'TRANSCRIBED';
      case MeetingStatus.failed:
        return 'FAILED';
    }
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
  Future<void> deleteMeeting(String id) async {
    try {
      // Convertir l'ID String en int pour l'API
      final meetingId = int.parse(id);
      await remoteDataSource.deleteMeeting(meetingId);
    } catch (e) {
      rethrow;
    }
  }
}

// Provider Riverpod pour injecter l'implémentation du Repository
// Il expose l'interface (MeetingRepository) et non l'implémentation
@riverpod
MeetingRepository meetingRepository(Ref ref) {
  final remoteDataSource = ref.watch(meetingRemoteDataSourceProvider);
  return MeetingRepositoryImpl(remoteDataSource);
}
