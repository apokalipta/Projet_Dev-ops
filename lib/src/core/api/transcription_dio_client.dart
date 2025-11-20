import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_config.dart';

part 'transcription_dio_client.g.dart';

/// Provider Dio pour le service de transcription
@riverpod
Dio transcriptionDio(TranscriptionDioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.getTranscriptionServiceUrl(),
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Intercepteur pour logger les requêtes (dev)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🎤 [TRANSCRIPTION] ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [TRANSCRIPTION] ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ [TRANSCRIPTION] ${error.response?.statusCode} ${error.requestOptions.uri}');
        print('   Error: ${error.message}');
        return handler.next(error);
      },
    ),
  );

  return dio;
}
