import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// État de l'enregistrement
class RecordingState {
  final bool isRecording;
  final bool isPaused;
  final double audioLevel;
  final String audioSource;
  final int segmentCount;
  final String? error;

  const RecordingState({
    this.isRecording = false,
    this.isPaused = false,
    this.audioLevel = 0.0,
    this.audioSource = 'default',
    this.segmentCount = 0,
    this.error,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isPaused,
    double? audioLevel,
    String? audioSource,
    int? segmentCount,
    String? error,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      audioLevel: audioLevel ?? this.audioLevel,
      audioSource: audioSource ?? this.audioSource,
      segmentCount: segmentCount ?? this.segmentCount,
      error: error,
    );
  }
}

/// Provider pour gérer l'enregistrement de réunion
class RecordingNotifier extends StateNotifier<RecordingState> {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _segmentTimer;
  Timer? _levelTimer;
  String? _currentMeetingId;
  String? _currentSegmentPath;
  DateTime? _segmentStartTime;

  RecordingNotifier() : super(const RecordingState());

  /// Démarrer l'enregistrement
  Future<void> startRecording(String meetingId) async {
    try {
      _currentMeetingId = meetingId;

      // Vérifier les permissions
      if (await _recorder.hasPermission() == false) {
        throw Exception('Permission microphone refusée');
      }

      // Créer le dossier pour les segments
      final directory = await _getRecordingDirectory();
      
      // Démarrer le premier segment
      await _startNewSegment(directory);

      // Timer pour créer un nouveau segment toutes les 1 minute
      _segmentTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
        await _saveAndStartNewSegment(directory);
      });

      // Timer pour mettre à jour le niveau audio
      _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        final amplitude = await _recorder.getAmplitude();
        final level = _amplitudeToLevel(amplitude.current);
        state = state.copyWith(audioLevel: level);
      });

      state = state.copyWith(isRecording: true, isPaused: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Démarrer un nouveau segment
  Future<void> _startNewSegment(Directory directory) async {
    _segmentStartTime = DateTime.now();
    final timestamp = _segmentStartTime!.millisecondsSinceEpoch;
    _currentSegmentPath = '${directory.path}/segment_$timestamp.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentSegmentPath!,
    );

    debugPrint('📹 Nouveau segment démarré: $_currentSegmentPath');
  }

  /// Sauvegarder le segment actuel et démarrer un nouveau
  Future<void> _saveAndStartNewSegment(Directory directory) async {
    if (!state.isRecording || state.isPaused) return;

    try {
      // Arrêter l'enregistrement actuel
      final path = await _recorder.stop();
      
      if (path != null) {
        // Envoyer le segment au serveur
        await _uploadSegment(path);
        
        // Incrémenter le compteur
        state = state.copyWith(segmentCount: state.segmentCount + 1);
      }

      // Démarrer un nouveau segment
      await _startNewSegment(directory);
    } catch (e) {
      debugPrint('❌ Erreur lors du changement de segment: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Envoyer un segment au serveur
  Future<void> _uploadSegment(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('⚠️ Fichier segment introuvable: $filePath');
        return;
      }

      final fileName = filePath.split('/').last;
      
      // TODO: Remplacer par l'URL réelle du serveur
      const serverUrl = 'http://localhost:8080/api/transcribe/segment';
      
      final formData = FormData.fromMap({
        'meetingId': _currentMeetingId,
        'segment': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        'timestamp': _segmentStartTime?.toIso8601String(),
      });

      final dio = Dio();
      final response = await dio.post(serverUrl, data: formData);

      if (response.statusCode == 200) {
        debugPrint('✅ Segment envoyé avec succès: $fileName');
        
        // Supprimer le fichier local après envoi réussi
        await file.delete();
      } else {
        debugPrint('⚠️ Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      // En cas d'erreur, garder le fichier localement
      debugPrint('❌ Erreur lors de l\'envoi du segment: $e');
      // Ne pas throw pour continuer l'enregistrement
    }
  }

  /// Mettre en pause l'enregistrement
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      _levelTimer?.cancel();
      state = state.copyWith(isPaused: true, audioLevel: 0.0);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reprendre l'enregistrement
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      
      // Redémarrer le timer de niveau audio
      _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        final amplitude = await _recorder.getAmplitude();
        final level = _amplitudeToLevel(amplitude.current);
        state = state.copyWith(audioLevel: level);
      });
      
      state = state.copyWith(isPaused: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Arrêter l'enregistrement
  Future<void> stopRecording() async {
    try {
      // Arrêter le dernier segment
      final path = await _recorder.stop();
      
      if (path != null) {
        // Envoyer le dernier segment
        await _uploadSegment(path);
      }

      // Envoyer une notification de fin au serveur
      await _notifyRecordingComplete();

      _cleanup();
      
      state = const RecordingState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Notifier le serveur que l'enregistrement est terminé
  Future<void> _notifyRecordingComplete() async {
    try {
      // TODO: Remplacer par l'URL réelle du serveur
      const serverUrl = 'http://localhost:8080/api/transcribe/complete';
      
      final dio = Dio();
      await dio.post(serverUrl, data: {
        'meetingId': _currentMeetingId,
        'segmentCount': state.segmentCount,
        'completedAt': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Enregistrement terminé notifié au serveur');
    } catch (e) {
      debugPrint('❌ Erreur lors de la notification de fin: $e');
    }
  }

  /// Changer la source audio
  Future<void> changeAudioSource(String source) async {
    state = state.copyWith(audioSource: source);
    
    // TODO: Implémenter le changement réel de source audio
    // Cela dépend des capacités du package record
    debugPrint('🎤 Source audio changée: $source');
  }

  /// Obtenir le répertoire d'enregistrement
  Future<Directory> _getRecordingDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingDir = Directory('${appDir.path}/recordings/$_currentMeetingId');
    
    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: true);
    }
    
    return recordingDir;
  }

  /// Convertir l'amplitude en niveau (0-100)
  double _amplitudeToLevel(double amplitude) {
    // L'amplitude est généralement entre -160 dB et 0 dB
    // On normalise entre 0 et 100
    final normalized = ((amplitude + 160) / 160) * 100;
    return normalized.clamp(0.0, 100.0);
  }

  /// Nettoyer les ressources
  void _cleanup() {
    _segmentTimer?.cancel();
    _levelTimer?.cancel();
    _recorder.dispose();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

/// Provider pour l'état de l'enregistrement
final recordingNotifierProvider = StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier();
});
