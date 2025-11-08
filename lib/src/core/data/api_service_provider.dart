import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/meeting_api_service.dart';
import '../api/transcription_api_service.dart';
import '../config/app_config.dart';
import 'mock_api_service.dart';

part 'api_service_provider.g.dart';

/// Provider qui retourne le service Meeting approprié selon la configuration
/// 
/// - Si `AppConfig.useMockData` est `true`, retourne MockApiService
/// - Sinon, retourne MeetingApiService (API réelle)
@riverpod
MeetingServiceInterface meetingService(MeetingServiceRef ref) {
  if (AppConfig.useMockData) {
    return MockMeetingServiceAdapter(ref.watch(mockApiServiceProvider));
  } else {
    return RealMeetingServiceAdapter(ref.watch(meetingApiServiceProvider));
  }
}

/// Provider qui retourne le service Transcription approprié selon la configuration
@riverpod
TranscriptionServiceInterface transcriptionService(
  TranscriptionServiceRef ref,
) {
  if (AppConfig.useMockData) {
    return MockTranscriptionServiceAdapter(ref.watch(mockApiServiceProvider));
  } else {
    return RealTranscriptionServiceAdapter(
      ref.watch(transcriptionApiServiceProvider),
    );
  }
}

// ============================================================================
// INTERFACES
// ============================================================================

/// Interface pour les services Meeting
abstract class MeetingServiceInterface {
  Future<Response> createMeeting(Map<String, dynamic> meetingData);
  Future<Response> getAllMeetings();
  Future<Response> getMeetingById(String meetingId);
  Future<Response> getMeetingParticipants(String meetingId);
  Future<Response> addParticipant(String meetingId, Map<String, dynamic> participantData);
  Future<Response> removeParticipant(String meetingId, String participantId);
  Future<Response> searchMeetingByTitle(String title);
}

/// Interface pour les services Transcription
abstract class TranscriptionServiceInterface {
  Future<Response> transcribeAudio(FormData audioData);
  Future<Response> getAllSegments(String meetingId);
  Future<Response> getSegmentById(String meetingId, String segmentId);
  Future<Response> updateSegmentText(String meetingId, String segmentId, Map<String, dynamic> textData);
  Future<Response> getSegmentSpeakers(String meetingId, String segmentId);
  Future<Response> updateSegmentSpeaker(String meetingId, String segmentId, String participantId);
  Future<Response> getRecordFile(String meetingId);
  Future<Response> getSegmentStartTime(String meetingId, String segmentId);
  Future<Response> getSegmentEndTime(String meetingId, String segmentId);
}

// ============================================================================
// ADAPTERS POUR MOCK API SERVICE
// ============================================================================

/// Adaptateur pour utiliser MockApiService comme MeetingServiceInterface
class MockMeetingServiceAdapter implements MeetingServiceInterface {
  final MockApiService _mockService;

  MockMeetingServiceAdapter(this._mockService);

  @override
  Future<Response> createMeeting(Map<String, dynamic> meetingData) {
    return _mockService.createMeeting(meetingData);
  }

  @override
  Future<Response> getAllMeetings() {
    return _mockService.getAllMeetings();
  }

  @override
  Future<Response> getMeetingById(String meetingId) {
    return _mockService.getMeetingById(meetingId);
  }

  @override
  Future<Response> getMeetingParticipants(String meetingId) {
    return _mockService.getMeetingParticipants(meetingId);
  }

  @override
  Future<Response> addParticipant(String meetingId, Map<String, dynamic> participantData) {
    return _mockService.addParticipant(meetingId, participantData);
  }

  @override
  Future<Response> removeParticipant(String meetingId, String participantId) {
    return _mockService.removeParticipant(meetingId, participantId);
  }

  @override
  Future<Response> searchMeetingByTitle(String title) {
    return _mockService.searchMeetingByTitle(title);
  }
}

/// Adaptateur pour utiliser MockApiService comme TranscriptionServiceInterface
class MockTranscriptionServiceAdapter implements TranscriptionServiceInterface {
  final MockApiService _mockService;

  MockTranscriptionServiceAdapter(this._mockService);

  @override
  Future<Response> transcribeAudio(FormData audioData) {
    return _mockService.transcribeAudio(audioData);
  }

  @override
  Future<Response> getAllSegments(String meetingId) {
    return _mockService.getAllSegments(meetingId);
  }

  @override
  Future<Response> getSegmentById(String meetingId, String segmentId) {
    return _mockService.getSegmentById(meetingId, segmentId);
  }

  @override
  Future<Response> updateSegmentText(String meetingId, String segmentId, Map<String, dynamic> textData) {
    return _mockService.updateSegmentText(meetingId, segmentId, textData);
  }

  @override
  Future<Response> getSegmentSpeakers(String meetingId, String segmentId) {
    return _mockService.getSegmentSpeakers(meetingId, segmentId);
  }

  @override
  Future<Response> updateSegmentSpeaker(String meetingId, String segmentId, String participantId) {
    return _mockService.updateSegmentSpeaker(meetingId, segmentId, participantId);
  }

  @override
  Future<Response> getRecordFile(String meetingId) {
    return _mockService.getRecordFile(meetingId);
  }

  @override
  Future<Response> getSegmentStartTime(String meetingId, String segmentId) {
    return _mockService.getSegmentStartTime(meetingId, segmentId);
  }

  @override
  Future<Response> getSegmentEndTime(String meetingId, String segmentId) {
    return _mockService.getSegmentEndTime(meetingId, segmentId);
  }
}

// ============================================================================
// ADAPTERS POUR REAL API SERVICES
// ============================================================================

/// Adaptateur pour utiliser MeetingApiService comme MeetingServiceInterface
class RealMeetingServiceAdapter implements MeetingServiceInterface {
  final MeetingApiService _apiService;

  RealMeetingServiceAdapter(this._apiService);

  @override
  Future<Response> createMeeting(Map<String, dynamic> meetingData) {
    return _apiService.createMeeting(meetingData);
  }

  @override
  Future<Response> getAllMeetings() {
    return _apiService.getAllMeetings();
  }

  @override
  Future<Response> getMeetingById(String meetingId) {
    return _apiService.getMeetingById(meetingId);
  }

  @override
  Future<Response> getMeetingParticipants(String meetingId) {
    return _apiService.getMeetingParticipants(meetingId);
  }

  @override
  Future<Response> addParticipant(String meetingId, Map<String, dynamic> participantData) {
    return _apiService.addParticipant(meetingId, participantData);
  }

  @override
  Future<Response> removeParticipant(String meetingId, String participantId) {
    return _apiService.removeParticipant(meetingId, participantId);
  }

  @override
  Future<Response> searchMeetingByTitle(String title) {
    return _apiService.searchMeetingByTitle(title);
  }
}

/// Adaptateur pour utiliser TranscriptionApiService comme TranscriptionServiceInterface
class RealTranscriptionServiceAdapter implements TranscriptionServiceInterface {
  final TranscriptionApiService _apiService;

  RealTranscriptionServiceAdapter(this._apiService);

  @override
  Future<Response> transcribeAudio(FormData audioData) {
    return _apiService.transcribeAudio(audioData);
  }

  @override
  Future<Response> getAllSegments(String meetingId) {
    return _apiService.getAllSegments(meetingId);
  }

  @override
  Future<Response> getSegmentById(String meetingId, String segmentId) {
    return _apiService.getSegmentById(meetingId, segmentId);
  }

  @override
  Future<Response> updateSegmentText(String meetingId, String segmentId, Map<String, dynamic> textData) {
    return _apiService.updateSegmentText(meetingId, segmentId, textData);
  }

  @override
  Future<Response> getSegmentSpeakers(String meetingId, String segmentId) {
    return _apiService.getSegmentSpeakers(meetingId, segmentId);
  }

  @override
  Future<Response> updateSegmentSpeaker(String meetingId, String segmentId, String participantId) {
    return _apiService.updateSegmentSpeaker(meetingId, segmentId, participantId);
  }

  @override
  Future<Response> getRecordFile(String meetingId) {
    return _apiService.getRecordFile(meetingId);
  }

  @override
  Future<Response> getSegmentStartTime(String meetingId, String segmentId) {
    return _apiService.getSegmentStartTime(meetingId, segmentId);
  }

  @override
  Future<Response> getSegmentEndTime(String meetingId, String segmentId) {
    return _apiService.getSegmentEndTime(meetingId, segmentId);
  }
}
