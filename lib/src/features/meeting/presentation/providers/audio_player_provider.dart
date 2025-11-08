import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/mock_audio_data.dart';
import '../../../../core/data/mock_data.dart';

part 'audio_player_provider.g.dart';

/// État du player audio
class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration currentPosition;
  final Duration totalDuration;
  final String? currentSegmentId;
  final String? error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentSegmentId,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? currentPosition,
    Duration? totalDuration,
    String? currentSegmentId,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentSegmentId: currentSegmentId ?? this.currentSegmentId,
      error: error,
    );
  }

  /// Obtenir le pourcentage de progression (0.0 à 1.0)
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }
}

/// Provider pour le player audio
@riverpod
class AudioPlayerNotifier extends _$AudioPlayerNotifier {
  AudioPlayer? _audioPlayer;
  String? _currentMeetingId;

  @override
  AudioPlayerState build() {
    // Nettoyer le player quand le provider est disposé
    ref.onDispose(() {
      _audioPlayer?.dispose();
    });

    return const AudioPlayerState();
  }

  /// Initialiser le player pour une réunion
  Future<void> initializePlayer(String meetingId) async {
    if (_currentMeetingId == meetingId && _audioPlayer != null) {
      // Déjà initialisé pour cette réunion
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Disposer l'ancien player si existant
      await _audioPlayer?.dispose();

      // Créer un nouveau player
      _audioPlayer = AudioPlayer();
      _currentMeetingId = meetingId;

      // Obtenir l'URL audio
      final audioUrl = MockAudioData.getAudioUrl(meetingId);
      if (audioUrl == null) {
        throw Exception('Aucun audio disponible pour cette réunion');
      }

      // Charger l'audio
      await _audioPlayer!.setUrl(audioUrl);

      // Écouter les changements de position
      _audioPlayer!.positionStream.listen((position) {
        final segments = MockData.getSegments(meetingId);
        final currentSegment = _findSegmentAtPosition(segments, position);

        state = state.copyWith(
          currentPosition: position,
          currentSegmentId: currentSegment?['id'] as String?,
        );
      });

      // Écouter les changements d'état de lecture
      _audioPlayer!.playingStream.listen((isPlaying) {
        state = state.copyWith(isPlaying: isPlaying);
      });

      // Écouter la durée totale
      _audioPlayer!.durationStream.listen((duration) {
        if (duration != null) {
          state = state.copyWith(totalDuration: duration);
        }
      });

      state = state.copyWith(
        isLoading: false,
        totalDuration: _audioPlayer!.duration ?? Duration.zero,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Jouer ou mettre en pause
  Future<void> togglePlayPause() async {
    if (_audioPlayer == null) return;

    if (_audioPlayer!.playing) {
      await _audioPlayer!.pause();
    } else {
      await _audioPlayer!.play();
    }
  }

  /// Jouer
  Future<void> play() async {
    await _audioPlayer?.play();
  }

  /// Pause
  Future<void> pause() async {
    await _audioPlayer?.pause();
  }

  /// Arrêter
  Future<void> stop() async {
    await _audioPlayer?.stop();
    state = state.copyWith(
      isPlaying: false,
      currentPosition: Duration.zero,
    );
  }

  /// Aller à une position spécifique
  Future<void> seek(Duration position) async {
    await _audioPlayer?.seek(position);
  }

  /// Aller à un segment spécifique
  Future<void> seekToSegment(String meetingId, String segmentId) async {
    final segments = MockData.getSegments(meetingId);
    final segment = segments.firstWhere(
      (s) => s['id'] == segmentId,
      orElse: () => {},
    );

    if (segment.isNotEmpty) {
      final startTime = segment['startTime'] as double;
      await seek(Duration(milliseconds: (startTime * 1000).toInt()));
    }
  }

  /// Avancer de 10 secondes
  Future<void> forward10() async {
    if (_audioPlayer == null) return;
    final newPosition = state.currentPosition + const Duration(seconds: 10);
    await seek(newPosition);
  }

  /// Reculer de 10 secondes
  Future<void> backward10() async {
    if (_audioPlayer == null) return;
    final newPosition = state.currentPosition - const Duration(seconds: 10);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  /// Changer la vitesse de lecture
  Future<void> setSpeed(double speed) async {
    await _audioPlayer?.setSpeed(speed);
  }

  /// Trouver le segment à une position donnée
  Map<String, dynamic>? _findSegmentAtPosition(
    List<Map<String, dynamic>> segments,
    Duration position,
  ) {
    final positionInSeconds = position.inMilliseconds / 1000;

    for (final segment in segments) {
      final startTime = segment['startTime'] as double;
      final endTime = segment['endTime'] as double;

      if (positionInSeconds >= startTime && positionInSeconds <= endTime) {
        return segment;
      }
    }

    return null;
  }

  /// Disposer le player
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _currentMeetingId = null;
  }
}
