// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingModelImpl _$$MeetingModelImplFromJson(Map<String, dynamic> json) =>
    _$MeetingModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['scheduledAt'] == null
          ? null
          : DateTime.parse(json['scheduledAt'] as String),
      language: json['language'] as String? ?? 'fr',
      status: json['status'] as String,
      duration: (json['durationMinutes'] as num?)?.toInt(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$MeetingModelImplToJson(_$MeetingModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'scheduledAt': instance.date?.toIso8601String(),
      'language': instance.language,
      'status': instance.status,
      'durationMinutes': instance.duration,
      'participants': instance.participants,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'description': instance.description,
    };

_$ParticipantModelImpl _$$ParticipantModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ParticipantModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      speakingOrder: (json['speakingOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ParticipantModelImplToJson(
        _$ParticipantModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'speakingOrder': instance.speakingOrder,
    };
