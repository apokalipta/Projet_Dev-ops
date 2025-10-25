import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_app/src/core/api/dio_client.dart';
import 'package:meeting_app/src/features/meeting/data/models/meeting_model.dart';

part 'meeting_remote_datasource.g.dart';

// Classe responsable des appels API bruts pour les réunions
class MeetingRemoteDataSource {
  final Dio dioClient;

  MeetingRemoteDataSource(this.dioClient);

  // GET /api/meetings
  Future<List<MeetingModel>> fetchMeetings() async {
    try {
      final response = await dioClient.get('/meetings');
      final List<dynamic> data = response.data as List;
      return data.map((json) => MeetingModel.fromJson(json)).toList();
    } on DioException {
      // Gérer les erreurs spécifiques (ex: 404, 500)
      rethrow;
    }
  }

  // POST /api/meetings
  Future<MeetingModel> createMeeting(Map<String, dynamic> meetingData) async {
    try {
      final response = await dioClient.post('/meetings', data: meetingData);
      return MeetingModel.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
  
  // TODO: Implémenter getMeetingById, updateMeeting, deleteMeeting
}

// Provider Riverpod pour injecter la source de données
@riverpod
MeetingRemoteDataSource meetingRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return MeetingRemoteDataSource(dio);
}
