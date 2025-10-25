import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/features/meeting/data/models/meeting_model.dart';

part 'meeting_mock_datasource.g.dart';

// Datasource mock pour le développement local
class MeetingMockDataSource {
  // Simuler un délai réseau
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Données de test conformes à l'architecture
  final List<MeetingModel> _mockMeetings = [
    MeetingModel(
      id: '550e8400-e29b-41d4-a716-446655440001',
      title: 'Réunion d\'équipe - Sprint Planning',
      date: DateTime.now().add(const Duration(hours: 2)),
      language: 'fr',
      status: 'scheduled',
      duration: 60,
      participants: [
        ParticipantModel(
          id: 'p1',
          name: 'Alice Dupont',
          email: 'alice.dupont@example.com',
          speakingOrder: 1,
        ),
        ParticipantModel(
          id: 'p2',
          name: 'Bob Martin',
          email: 'bob.martin@example.com',
          speakingOrder: 2,
        ),
        ParticipantModel(
          id: 'p3',
          name: 'Charlie Bernard',
          email: 'charlie.bernard@example.com',
          speakingOrder: 3,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MeetingModel(
      id: '550e8400-e29b-41d4-a716-446655440002',
      title: 'Revue de projet - Application Mobile',
      date: DateTime.now().add(const Duration(days: 1, hours: 10)),
      language: 'fr',
      status: 'scheduled',
      duration: 90,
      participants: [
        ParticipantModel(
          id: 'p4',
          name: 'David Leroy',
          email: 'david.leroy@example.com',
          speakingOrder: 1,
        ),
        ParticipantModel(
          id: 'p5',
          name: 'Emma Petit',
          email: 'emma.petit@example.com',
          speakingOrder: 2,
        ),
        ParticipantModel(
          id: 'p6',
          name: 'Frank Dubois',
          email: 'frank.dubois@example.com',
          speakingOrder: 3,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MeetingModel(
      id: '550e8400-e29b-41d4-a716-446655440003',
      title: 'Brainstorming - Nouvelles Fonctionnalités',
      date: DateTime.now().subtract(const Duration(days: 1)),
      language: 'fr',
      status: 'transcribed',
      duration: 120,
      participants: [
        ParticipantModel(
          id: 'p7',
          name: 'Grace Moreau',
          email: 'grace.moreau@example.com',
          speakingOrder: 1,
        ),
        ParticipantModel(
          id: 'p8',
          name: 'Henry Laurent',
          email: 'henry.laurent@example.com',
          speakingOrder: 2,
        ),
        ParticipantModel(
          id: 'p9',
          name: 'Iris Simon',
          email: 'iris.simon@example.com',
          speakingOrder: 3,
        ),
        ParticipantModel(
          id: 'p10',
          name: 'Jack Michel',
          email: 'jack.michel@example.com',
          speakingOrder: 4,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    MeetingModel(
      id: '550e8400-e29b-41d4-a716-446655440004',
      title: 'Réunion Client - Présentation POC',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      language: 'fr',
      status: 'completed',
      duration: 45,
      participants: [
        ParticipantModel(
          id: 'p11',
          name: 'Sophie Rousseau',
          email: 'sophie.rousseau@example.com',
          speakingOrder: 1,
        ),
        ParticipantModel(
          id: 'p12',
          name: 'Thomas Blanc',
          email: 'thomas.blanc@example.com',
          speakingOrder: 2,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // GET /api/meetings
  Future<List<MeetingModel>> fetchMeetings() async {
    await _simulateNetworkDelay();
    return List.from(_mockMeetings);
  }

  // POST /api/meetings
  Future<MeetingModel> createMeeting(Map<String, dynamic> meetingData) async {
    await _simulateNetworkDelay();
    
    final now = DateTime.now();
    final newMeeting = MeetingModel(
      id: '550e8400-e29b-41d4-a716-${now.millisecondsSinceEpoch}',
      title: meetingData['title'] ?? 'Nouvelle réunion',
      date: DateTime.parse(meetingData['date']),
      language: meetingData['language'] ?? 'fr',
      status: meetingData['status'] ?? 'scheduled',
      duration: meetingData['duration'],
      participants: (meetingData['participants'] as List<dynamic>?)
          ?.map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: now,
      updatedAt: now,
    );
    
    _mockMeetings.add(newMeeting);
    return newMeeting;
  }

  // GET /api/meetings/:id
  Future<MeetingModel> getMeetingById(String id) async {
    await _simulateNetworkDelay();
    return _mockMeetings.firstWhere(
      (meeting) => meeting.id == id,
      orElse: () => throw Exception('Meeting not found'),
    );
  }

  // PUT /api/meetings/:id
  Future<MeetingModel> updateMeeting(String id, Map<String, dynamic> meetingData) async {
    await _simulateNetworkDelay();
    
    final index = _mockMeetings.indexWhere((meeting) => meeting.id == id);
    if (index == -1) throw Exception('Meeting not found');
    
    final currentMeeting = _mockMeetings[index];
    final updatedMeeting = currentMeeting.copyWith(
      title: meetingData['title'] ?? currentMeeting.title,
      date: meetingData['date'] != null 
          ? DateTime.parse(meetingData['date']) 
          : currentMeeting.date,
      language: meetingData['language'] ?? currentMeeting.language,
      status: meetingData['status'] ?? currentMeeting.status,
      duration: meetingData['duration'] ?? currentMeeting.duration,
      participants: meetingData['participants'] != null 
          ? (meetingData['participants'] as List<dynamic>)
              .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
              .toList()
          : currentMeeting.participants,
      updatedAt: DateTime.now(),
    );
    
    _mockMeetings[index] = updatedMeeting;
    return updatedMeeting;
  }

  // DELETE /api/meetings/:id
  Future<void> deleteMeeting(String id) async {
    await _simulateNetworkDelay();
    _mockMeetings.removeWhere((meeting) => meeting.id == id);
  }
}

// Provider Riverpod pour injecter la source de données mock
@riverpod
MeetingMockDataSource meetingMockDataSource(Ref ref) {
  return MeetingMockDataSource();
}
