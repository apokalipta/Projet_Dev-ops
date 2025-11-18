import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/recording_provider.dart';

/// Écran d'enregistrement de réunion en direct
class MeetingRecordingScreen extends ConsumerStatefulWidget {
  final String meetingId;
  final String meetingTitle;

  const MeetingRecordingScreen({
    super.key,
    required this.meetingId,
    required this.meetingTitle,
  });

  @override
  ConsumerState<MeetingRecordingScreen> createState() => _MeetingRecordingScreenState();
}

class _MeetingRecordingScreenState extends ConsumerState<MeetingRecordingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    
    // Animation pour le bouton d'enregistrement
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Démarrer l'enregistrement automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });

    // Timer pour le temps écoulé
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      await ref.read(recordingNotifierProvider.notifier).startRecording(widget.meetingId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    // Confirmation avant d'arrêter
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la réunion'),
        content: const Text('Voulez-vous vraiment terminer l\'enregistrement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Terminer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finalisation de l\'enregistrement...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        await ref.read(recordingNotifierProvider.notifier).stopRecording();
        
        if (mounted) {
          // Fermer le dialog de chargement
          Navigator.pop(context);
          
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Réunion terminée et enregistrée avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Attendre un peu pour que l'utilisateur voie le message
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Retour à la liste des réunions
          if (mounted) {
            context.go('/meetings');
          }
        }
      } catch (e) {
        if (mounted) {
          // Fermer le dialog de chargement
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Erreur lors de l\'arrêt: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingNotifierProvider);

    return WillPopScope(
      onWillPop: () async {
        // Empêcher le retour arrière accidentel
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter l\'enregistrement'),
            content: const Text('L\'enregistrement sera arrêté. Continuer ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Quitter'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.meetingTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Timer
              _buildTimer(),
              
              const SizedBox(height: 60),
              
              // Égaliseur audio
              Expanded(
                child: _buildAudioVisualizer(recordingState),
              ),
              
              const SizedBox(height: 40),
              
              // Sélecteur de source audio
              _buildAudioSourceSelector(recordingState),
              
              const SizedBox(height: 30),
              
              // Contrôles
              _buildControls(recordingState),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Timer affichant le temps écoulé
  Widget _buildTimer() {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    return Column(
      children: [
        const Text(
          'ENREGISTREMENT EN COURS',
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Indicateur rouge clignotant
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3 + (_pulseController.value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Temps
            Text(
              hours > 0
                  ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
                  : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Visualiseur audio (égaliseur)
  Widget _buildAudioVisualizer(RecordingState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Égaliseur
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(20, (index) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  // Simuler des barres d'égaliseur animées
                  final baseHeight = 20.0;
                  final maxHeight = 150.0;
                  final offset = (index * 0.1) % 1.0;
                  final animValue = (_pulseController.value + offset) % 1.0;
                  final height = state.isRecording
                      ? baseHeight + (maxHeight - baseHeight) * animValue * (state.audioLevel / 100)
                      : baseHeight;

                  return Container(
                    width: 6,
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.green,
                          Colors.yellow,
                          Colors.red,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              );
            }),
          ),
          
          const SizedBox(height: 30),
          
          // Niveau audio
          Text(
            'Niveau: ${state.audioLevel.toStringAsFixed(0)}%',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Sélecteur de source audio
  Widget _buildAudioSourceSelector(RecordingState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Source audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: state.audioSource,
            dropdownColor: Colors.grey[850],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: const [
              DropdownMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.mic, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text('Microphone par défaut'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'phone',
                child: Row(
                  children: [
                    Icon(Icons.phone_android, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text('Microphone téléphone'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'headset',
                child: Row(
                  children: [
                    Icon(Icons.headset, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text('Casque/Écouteurs'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'bluetooth',
                child: Row(
                  children: [
                    Icon(Icons.bluetooth_audio, size: 18, color: Colors.white70),
                    SizedBox(width: 8),
                    Text('Bluetooth'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(recordingNotifierProvider.notifier).changeAudioSource(value);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Contrôles (pause, stop)
  Widget _buildControls(RecordingState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bouton Pause/Reprendre
        _buildControlButton(
          icon: state.isPaused ? Icons.play_arrow : Icons.pause,
          label: state.isPaused ? 'Reprendre' : 'Pause',
          color: Colors.orange,
          onPressed: () {
            if (state.isPaused) {
              ref.read(recordingNotifierProvider.notifier).resumeRecording();
            } else {
              ref.read(recordingNotifierProvider.notifier).pauseRecording();
            }
          },
        ),
        
        const SizedBox(width: 40),
        
        // Bouton Stop
        _buildControlButton(
          icon: Icons.stop,
          label: 'Terminer',
          color: Colors.red,
          onPressed: _stopRecording,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
