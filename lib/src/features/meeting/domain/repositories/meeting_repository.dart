import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';

// Le contrat (classe abstraite) défini dans la couche Domaine
abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings();
  
  Future<Meeting> getMeetingById(String id);
  
  Future<Meeting> createMeeting(Meeting meeting);
  
  Future<void> updateMeeting(Meeting meeting);
  
  Future<void> deleteMeeting(String id);
}