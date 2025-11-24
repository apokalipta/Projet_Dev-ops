import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
// Mock data imports removed - using real backend
import '../providers/audio_player_provider.dart';

/// Écran de lecture d'une réunion avec player audio synchronisé
class MeetingPlaybackScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingPlaybackScreen({
    super.key,
    required this.meetingId,
  });

  @override
  ConsumerState<MeetingPlaybackScreen> createState() =>
      _MeetingPlaybackScreenState();
}

class _MeetingPlaybackScreenState extends ConsumerState<MeetingPlaybackScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _segmentKeys = {};
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialiser le player au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(audioPlayerNotifierProvider.notifier)
          .initializePlayer(widget.meetingId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch from backend API
    final meeting = widget.meetingId == 'demo-999' 
      ? {'title': '🎬 Réunion de Démonstration'} 
      : null; // Will be implemented with backend API
    final segments = widget.meetingId == 'demo-999' 
      ? _getDemoSegments() 
      : <Map<String, dynamic>>[]; // Will be implemented with backend API
    final hasAudio = widget.meetingId == 'demo-999'; // Demo meeting has audio
    final playerState = ref.watch(audioPlayerNotifierProvider);

    if (meeting == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Réunion non trouvée')),
      );
    }

    if (!hasAudio) {
      return Scaffold(
        appBar: AppBar(title: Text(meeting['title'] as String)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.audiotrack_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Aucun enregistrement audio disponible'),
            ],
          ),
        ),
      );
    }

    // Créer les clés pour chaque segment
    for (final segment in segments) {
      final segmentId = segment['id'] as String;
      _segmentKeys.putIfAbsent(segmentId, () => GlobalKey());
    }

    // Scroll automatique vers le segment actuel
    if (playerState.currentSegmentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSegment(playerState.currentSegmentId!);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting['title'] as String),
        actions: [
          // Menu vitesse de lecture
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed),
            onSelected: (speed) {
              setState(() => _playbackSpeed = speed);
              ref
                  .read(audioPlayerNotifierProvider.notifier)
                  .setSpeed(speed);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.5, child: Text('0.5x')),
              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
              const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
              const PopupMenuItem(value: 2.0, child: Text('2.0x')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Player audio fixe en haut
          _buildAudioPlayer(playerState),

          const Divider(height: 1),

          // Liste des segments avec scroll
          Expanded(
            child: segments.isEmpty
                ? const Center(
                    child: Text('Aucune transcription disponible'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: segments.length,
                    itemBuilder: (context, index) {
                      final segment = segments[index];
                      final segmentId = segment['id'] as String;
                      final isCurrentSegment =
                          playerState.currentSegmentId == segmentId;

                      return _buildSegmentCard(
                        segment,
                        isCurrentSegment,
                        _segmentKeys[segmentId]!,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Widget du player audio
  Widget _buildAudioPlayer(AudioPlayerState playerState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de progression
          ProgressBar(
            progress: playerState.currentPosition,
            total: playerState.totalDuration,
            buffered: playerState.totalDuration,
            onSeek: (duration) {
              ref.read(audioPlayerNotifierProvider.notifier).seek(duration);
            },
            barHeight: 4,
            thumbRadius: 8,
            timeLabelLocation: TimeLabelLocation.sides,
            timeLabelTextStyle: const TextStyle(fontSize: 12),
          ),

          const SizedBox(height: 16),

          // Contrôles de lecture
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reculer 10s
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: playerState.isLoading
                    ? null
                    : () {
                        ref
                            .read(audioPlayerNotifierProvider.notifier)
                            .backward10();
                      },
              ),

              const SizedBox(width: 16),

              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: IconButton(
                  icon: Icon(
                    playerState.isLoading
                        ? Icons.hourglass_empty
                        : playerState.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                  ),
                  iconSize: 48,
                  color: Colors.white,
                  onPressed: playerState.isLoading
                      ? null
                      : () {
                          ref
                              .read(audioPlayerNotifierProvider.notifier)
                              .togglePlayPause();
                        },
                ),
              ),

              const SizedBox(width: 16),

              // Avancer 10s
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: playerState.isLoading
                    ? null
                    : () {
                        ref
                            .read(audioPlayerNotifierProvider.notifier)
                            .forward10();
                      },
              ),
            ],
          ),

          // Indicateur de vitesse
          if (_playbackSpeed != 1.0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Vitesse: ${_playbackSpeed}x',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

          // Erreur
          if (playerState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Erreur: ${playerState.error}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget d'un segment de transcription
  Widget _buildSegmentCard(
    Map<String, dynamic> segment,
    bool isCurrentSegment,
    GlobalKey key,
  ) {
    final speakerName = segment['speakerName'] as String? ?? 'Inconnu';
    final confidence = segment['confidence'] as double;
    final startTime = segment['startTime'] as double;
    final endTime = segment['endTime'] as double;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: isCurrentSegment ? 4 : 1,
        color: isCurrentSegment
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        child: InkWell(
          onTap: () {
            // Aller à ce segment
            ref
                .read(audioPlayerNotifierProvider.notifier)
                .seekToSegment(widget.meetingId, segment['id'] as String);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec locuteur et temps
                Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 20,
                      child: Text(
                        speakerName.isNotEmpty ? speakerName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Nom
                    Expanded(
                      child: Text(
                        speakerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrentSegment
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ),
                    ),

                    // Temps
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(startTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrentSegment
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            fontWeight: isCurrentSegment
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Text(
                          '${(endTime - startTime).toStringAsFixed(1)}s',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Texte transcrit
                Text(
                  segment['text'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: isCurrentSegment ? FontWeight.w500 : null,
                  ),
                ),

                const SizedBox(height: 12),

                // Indicateur de confiance
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: confidence,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          confidence > 0.9
                              ? Colors.green
                              : confidence > 0.8
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                // Indicateur de lecture en cours
                if (isCurrentSegment)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.play_circle_filled,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'En cours de lecture',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formater le temps en mm:ss
  String _formatTime(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Scroller vers un segment
  void _scrollToSegment(String segmentId) {
    final key = _segmentKeys[segmentId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.2, // Position à 20% du haut de l'écran
      );
    }
  }

  /// Segments de démonstration pour la réunion mockée
  List<Map<String, dynamic>> _getDemoSegments() {
    return [
      {
        'id': 'seg-1',
        'text': 'Bonjour à tous, merci d\'être présents pour cette réunion de démonstration. Aujourd\'hui, nous allons discuter des fonctionnalités de notre application de transcription.',
        'startTime': 0.0,
        'endTime': 8.5,
        'speakerId': 'p1',
        'speakerName': 'Alice Martin',
        'confidence': 0.95,
      },
      {
        'id': 'seg-2',
        'text': 'Merci Alice. Je suis ravi de participer à cette démonstration. L\'interface utilisateur a l\'air vraiment intuitive.',
        'startTime': 9.0,
        'endTime': 15.2,
        'speakerId': 'p2',
        'speakerName': 'Bob Dupont',
        'confidence': 0.92,
      },
      {
        'id': 'seg-3',
        'text': 'Oui, je suis d\'accord avec Bob. Les fonctionnalités de recherche et d\'édition sont particulièrement impressionnantes. Pouvons-nous voir comment fonctionne la modification des segments ?',
        'startTime': 15.8,
        'endTime': 25.3,
        'speakerId': 'p3',
        'speakerName': 'Claire Dubois',
        'confidence': 0.89,
      },
      {
        'id': 'seg-4',
        'text': 'Bien sûr Claire. Vous pouvez cliquer sur n\'importe quel segment pour l\'éditer. Le système sauvegarde automatiquement vos modifications et vous pouvez également changer le locuteur si l\'IA s\'est trompée.',
        'startTime': 26.0,
        'endTime': 36.5,
        'speakerId': 'p1',
        'speakerName': 'Alice Martin',
        'confidence': 0.94,
      },
      {
        'id': 'seg-5',
        'text': 'C\'est excellent ! Et qu\'en est-il de l\'export en PDF ? J\'ai vu qu\'il y avait un bouton pour télécharger la transcription.',
        'startTime': 37.2,
        'endTime': 43.8,
        'speakerId': 'p2',
        'speakerName': 'Bob Dupont',
        'confidence': 0.91,
      },
      {
        'id': 'seg-6',
        'text': 'Exactement. Le système génère un PDF professionnel avec tous les segments, les locuteurs identifiés, et les horodatages. Vous pouvez également partager la transcription directement depuis l\'application.',
        'startTime': 44.5,
        'endTime': 55.0,
        'speakerId': 'p1',
        'speakerName': 'Alice Martin',
        'confidence': 0.96,
      },
      {
        'id': 'seg-7',
        'text': 'J\'aimerais aussi mentionner la fonctionnalité de lecture audio synchronisée. Quand on clique sur un segment, l\'audio saute directement à ce moment de la réunion. C\'est très pratique pour vérifier le contexte.',
        'startTime': 55.8,
        'endTime': 66.2,
        'speakerId': 'p3',
        'speakerName': 'Claire Dubois',
        'confidence': 0.93,
      },
      {
        'id': 'seg-8',
        'text': 'Absolument. Et n\'oublions pas la fonction de recherche qui permet de trouver rapidement des mots-clés dans toute la transcription. C\'est un gain de temps considérable.',
        'startTime': 67.0,
        'endTime': 75.5,
        'speakerId': 'p1',
        'speakerName': 'Alice Martin',
        'confidence': 0.95,
      },
      {
        'id': 'seg-9',
        'text': 'Pour conclure, je pense que cette application va vraiment faciliter notre travail. La qualité de la transcription est remarquable et l\'interface est très bien pensée.',
        'startTime': 76.2,
        'endTime': 85.0,
        'speakerId': 'p2',
        'speakerName': 'Bob Dupont',
        'confidence': 0.90,
      },
      {
        'id': 'seg-10',
        'text': 'Merci à tous pour vos retours positifs. N\'hésitez pas à tester toutes les fonctionnalités et à nous faire part de vos suggestions d\'amélioration. À bientôt !',
        'startTime': 85.8,
        'endTime': 94.5,
        'speakerId': 'p1',
        'speakerName': 'Alice Martin',
        'confidence': 0.97,
      },
    ];
  }
}
