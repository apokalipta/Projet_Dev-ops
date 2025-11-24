import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/transcription_remote_datasource.dart';
import '../../data/datasources/meeting_remote_datasource.dart';

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
  final TranscriptionRemoteDataSource _transcriptionDataSource;
  final MeetingRemoteDataSource _meetingDataSource;
  Timer? _segmentTimer;
  Timer? _levelTimer;
  String? _currentMeetingId;
  String? _currentSegmentPath;
  DateTime? _segmentStartTime;
  bool _transcriptionStarted = false;

  RecordingNotifier(
    this._transcriptionDataSource,
    this._meetingDataSource,
  ) : super(const RecordingState());

  /// Démarrer l'enregistrement
  Future<void> startRecording(String meetingId) async {
    try {
      _currentMeetingId = meetingId;

      // Vérifier les permissions
      if (await _recorder.hasPermission() == false) {
        throw Exception('Permission microphone refusée');
      }

      // Démarrer la réunion sur le backend (CRITIQUE)
      try {
        await _meetingDataSource.startMeeting(int.parse(meetingId));
        debugPrint('✅ Réunion démarrée sur le backend (statut: IN_PROGRESS)');
      } catch (e) {
        debugPrint('❌ ERREUR CRITIQUE: Impossible de démarrer la réunion: $e');
        throw Exception('Impossible de démarrer la réunion sur le serveur: $e');
      }

      // Créer la transcription sur le backend
      if (!_transcriptionStarted) {
        try {
          await _transcriptionDataSource.startTranscription(
            meetingId,
            recordFileName: 'meeting_${meetingId}_${DateTime.now().millisecondsSinceEpoch}.mp3',
          );
          _transcriptionStarted = true;
          debugPrint('✅ Transcription créée sur le backend');
        } catch (e) {
          debugPrint('⚠️ Erreur lors de la création de la transcription: $e');
        }
      }

      // Créer le dossier pour les segments
      final directory = await _getRecordingDirectory();
      
      // Démarrer le premier segment
      await _startNewSegment(directory);

      // Timer pour créer un nouveau segment toutes les 1 minute 30 secondes
      _segmentTimer = Timer.periodic(const Duration(seconds: 90), (timer) async {
        await _saveAndStartNewSegment(directory);
      });

      // Timer pour mettre à jour le niveau audio
      _levelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        final amplitude = await _recorder.getAmplitude();
        final level = _amplitudeToLevel(amplitude.current);
        state = state.copyWith(audioLevel: level);
      });

      state = state.copyWith(isRecording: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Démarrer un nouveau segment
  Future<void> _startNewSegment(Directory directory) async {
    _segmentStartTime = DateTime.now();
    // Utiliser le compteur de segments pour le nom (1.m4a, 2.m4a, etc.)
    final segmentNumber = state.segmentCount + 1;
    _currentSegmentPath = '${directory.path}/$segmentNumber.m4a';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc, // AAC pour compatibilité Android/iOS
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentSegmentPath!,
    );

    debugPrint('📹 Nouveau segment démarré: $_currentSegmentPath');
  }

  /// Sauvegarder le segment actuel et démarrer un nouveau
  Future<void> _saveAndStartNewSegment(Directory directory) async {
    if (!state.isRecording) return;

    try {
      // Arrêter l'enregistrement actuel
      final path = await _recorder.stop();
      
      if (path != null) {
        // Incrémenter le compteur AVANT d'envoyer pour que le prochain segment ait le bon numéro
        state = state.copyWith(segmentCount: state.segmentCount + 1);
        
        // Envoyer le segment au serveur
        await _uploadSegment(path);
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

      if (_currentMeetingId == null) {
        debugPrint('⚠️ ID de réunion manquant');
        return;
      }

      final fileName = filePath.split('/').last;
      
      // Envoyer le segment au service de transcription (M4A/AAC)
      // Le backend convertira en MP3 si nécessaire
      final response = await _transcriptionDataSource.sendAudioSegment(
        _currentMeetingId!,
        filePath,
      );

      if (response.statusCode == 202 || response.statusCode == 200) {
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

  /// Arrêter l'enregistrement
  Future<void> stopRecording() async {
    try {
      // Vérifier si l'enregistrement est actif
      if (!state.isRecording) {
        debugPrint('⚠️ Enregistrement déjà arrêté');
        return;
      }

      // Arrêter les timers d'abord
      _segmentTimer?.cancel();
      _levelTimer?.cancel();

      // Arrêter le dernier segment
      final path = await _recorder.stop();
      
      if (path != null) {
        // Envoyer le dernier segment
        await _uploadSegment(path);
      }

      // Envoyer une notification de fin au serveur
      await _notifyRecordingComplete();

      // Nettoyer les ressources
      _currentMeetingId = null;
      _currentSegmentPath = null;
      _segmentStartTime = null;
      _transcriptionStarted = false;
      
      state = const RecordingState();
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'arrêt: $e');
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Notifier le serveur que l'enregistrement est terminé
  Future<void> _notifyRecordingComplete() async {
    try {
      if (_currentMeetingId == null) {
        debugPrint('⚠️ ID de réunion manquant');
        return;
      }

      // Terminer la réunion sur le backend Meeting-service (CRITIQUE)
      try {
        await _meetingDataSource.endMeeting(int.parse(_currentMeetingId!));
        debugPrint('✅ Réunion terminée sur le backend (statut: COMPLETED)');
      } catch (e) {
        debugPrint('❌ ERREUR CRITIQUE: Impossible de terminer la réunion: $e');
        // Ne pas throw ici car l'enregistrement est déjà arrêté
        // Mais logger l'erreur pour investigation
      }

      debugPrint('✅ Enregistrement terminé - ${state.segmentCount} segments envoyés');
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

  @override
  void dispose() {
    _segmentTimer?.cancel();
    _levelTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}

/// Provider pour l'état de l'enregistrement
final recordingNotifierProvider = StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  final transcriptionDataSource = ref.watch(transcriptionRemoteDataSourceProvider);
  final meetingDataSource = ref.watch(meetingRemoteDataSourceProvider);
  return RecordingNotifier(transcriptionDataSource, meetingDataSource);
});
