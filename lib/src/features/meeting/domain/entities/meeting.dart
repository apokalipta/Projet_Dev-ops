import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';

// Une entité de domaine pure, générée avec Freezed
// Ne contient pas de logique 'fromJson'/'toJson'
@freezed
class Meeting with _$Meeting {
  const factory Meeting({
    required String id,
    required String title,
    required DateTime date,
    @Default('fr') String language,
    required MeetingStatus status,
    int? duration, // Durée en minutes
    required List<Participant> participants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Meeting;
}

// Entité Participant
@freezed
class Participant with _$Participant {
  const factory Participant({
    required String id,
    required String name,
    String? email,
    int? speakingOrder,
  }) = _Participant;
}

// Enum pour le statut de la réunion
enum MeetingStatus {
  scheduled,    // Planifiée
  inProgress,   // En cours
  completed,    // Terminée
  transcribed,  // Transcrite
  failed,       // Échec transcription
}
