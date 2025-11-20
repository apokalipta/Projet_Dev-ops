import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';

part 'meeting_model.freezed.dart';
part 'meeting_model.g.dart';

// DTO (Data Transfer Object) pour la couche de données
// Traduit directement le JSON de l'API
@freezed
class MeetingModel with _$MeetingModel {
  const factory MeetingModel({
    required String id,
    required String title,
    @JsonKey(name: 'scheduledAt') DateTime? date, // Backend utilise scheduledAt
    @Default('fr') String language,
    required String status, // String pour faciliter JSON
    @JsonKey(name: 'durationMinutes') int? duration, // Backend utilise durationMinutes
    @Default([]) List<ParticipantModel> participants, // Peut être vide
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description, // Ajout du champ description
  }) = _MeetingModel;

  const MeetingModel._();

  factory MeetingModel.fromJson(Map<String, dynamic> json) =>
      _$MeetingModelFromJson(json);

  // Méthode de conversion du DTO (Modèle) vers l'Entité de domaine
  Meeting toEntity() {
    return Meeting(
      id: id,
      title: title,
      date: date ?? DateTime.now(), // Utiliser DateTime.now() si null
      language: language,
      status: _parseStatus(status),
      duration: duration,
      participants: participants.map((p) => p.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }

  static MeetingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return MeetingStatus.scheduled;
      case 'in_progress':
        return MeetingStatus.inProgress;
      case 'completed':
        return MeetingStatus.completed;
      case 'transcribed':
        return MeetingStatus.transcribed;
      case 'failed':
        return MeetingStatus.failed;
      default:
        return MeetingStatus.scheduled;
    }
  }
}

// DTO pour Participant
@freezed
class ParticipantModel with _$ParticipantModel {
  const factory ParticipantModel({
    required String id,
    required String name,
    String? email,
    int? speakingOrder,
  }) = _ParticipantModel;

  const ParticipantModel._();

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);

  Participant toEntity() {
    return Participant(
      id: id,
      name: name,
      email: email,
      speakingOrder: speakingOrder,
    );
  }
}
