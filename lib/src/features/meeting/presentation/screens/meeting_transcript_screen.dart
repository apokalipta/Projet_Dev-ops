import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/data/mock_data.dart';
import '../providers/audio_player_provider.dart';

/// Écran d'affichage de la transcription d'une réunion
class MeetingTranscriptScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingTranscriptScreen({
    super.key,
    required this.meetingId,
  });

  @override
  ConsumerState<MeetingTranscriptScreen> createState() => _MeetingTranscriptScreenState();
}

class _MeetingTranscriptScreenState extends ConsumerState<MeetingTranscriptScreen> {
  // Map pour stocker les textes édités (segmentId -> texte modifié)
  final Map<String, String> _editedTexts = {};
  
  // Contrôleur de recherche
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _showAudioPlayer = false;
  
  @override
  void initState() {
    super.initState();
    // Charger l'audio après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAudio();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAudio() async {
    // Charger l'audio depuis les assets
    // Note: Le fichier audio.mp3 doit être placé dans assets/audio/
    try {
      await ref.read(audioPlayerNotifierProvider.notifier).initializePlayer(widget.meetingId);
    } catch (e) {
      // Ignorer l'erreur si le fichier n'existe pas encore
      debugPrint('Audio non chargé: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSegments = MockData.getSegments(widget.meetingId);
    final audioState = ref.watch(audioPlayerNotifierProvider);
    
    // Filtrer les segments selon la recherche
    final segments = _searchQuery.isEmpty
        ? allSegments
        : allSegments.where((segment) {
            final text = (_editedTexts[segment['id']] ?? segment['text'] as String).toLowerCase();
            final speaker = (segment['speakerName'] as String? ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();
            return text.contains(query) || speaker.contains(query);
          }).toList();

    if (segments.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transcription')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.text_snippet_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Aucune transcription disponible',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          // Player audio (affichable/masquable)
          if (_showAudioPlayer) _buildAudioPlayer(audioState),
          
          // Liste des segments
          Expanded(
            child: _buildSegmentsList(segments),
          ),
        ],
      ),
    );
  }
  
  /// AppBar normale
  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('Transcription'),
      actions: [
        IconButton(
          icon: Icon(_showAudioPlayer ? Icons.music_note : Icons.music_note_outlined),
          onPressed: () {
            setState(() {
              _showAudioPlayer = !_showAudioPlayer;
            });
          },
          tooltip: _showAudioPlayer ? 'Masquer le lecteur' : 'Afficher le lecteur',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          tooltip: 'Rechercher',
        ),
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: _showDownloadOptions,
          tooltip: 'Télécharger',
        ),
      ],
    );
  }
  
  /// AppBar de recherche
  AppBar _buildSearchAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchQuery = '';
            _searchController.clear();
          });
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Rechercher un mot ou un interlocuteur...',
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          ),
      ],
    );
  }
  
  /// Player audio
  Widget _buildAudioPlayer(AudioPlayerState audioState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
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
            progress: audioState.currentPosition,
            total: audioState.totalDuration == Duration.zero 
                ? const Duration(seconds: 1) // Éviter division par zéro
                : audioState.totalDuration,
            onSeek: (duration) {
              ref.read(audioPlayerNotifierProvider.notifier).seek(duration);
            },
            barHeight: 3,
            thumbRadius: 6,
            timeLabelTextStyle: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          
          // Affichage de la durée (debug)
          if (audioState.totalDuration != Duration.zero)
            Text(
              'Durée: ${_formatDuration(audioState.totalDuration)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          const SizedBox(height: 8),
          
          // Contrôles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reculer 10s
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 28,
                onPressed: audioState.isLoading ? null : () {
                  ref.read(audioPlayerNotifierProvider.notifier).backward10();
                },
              ),
              const SizedBox(width: 16),
              
              // Play/Pause
              if (audioState.isLoading)
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    audioState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  ),
                  iconSize: 48,
                  onPressed: () {
                    ref.read(audioPlayerNotifierProvider.notifier).togglePlayPause();
                  },
                ),
              const SizedBox(width: 16),
              
              // Avancer 10s
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 28,
                onPressed: audioState.isLoading ? null : () {
                  ref.read(audioPlayerNotifierProvider.notifier).forward10();
                },
              ),
            ],
          ),
          
          if (audioState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                audioState.error!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Liste des segments
  Widget _buildSegmentsList(List<Map<String, dynamic>> segments) {
    if (segments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.text_snippet_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune transcription disponible'
                  : 'Aucun résultat pour "$_searchQuery"',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return
    ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return _buildSegmentCard(segment);
      },
    );
  }
  
  /// Afficher les options de téléchargement
  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Télécharger',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez ce que vous souhaitez télécharger',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Télécharger la transcription
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Transcription (PDF)'),
              subtitle: const Text('Document PDF formaté'),
              onTap: () {
                Navigator.pop(context);
                _downloadTranscript();
              },
            ),
            
            // Télécharger l'audio
            ListTile(
              leading: const Icon(Icons.audiotrack, color: Colors.green),
              title: const Text('Audio (MP3)'),
              subtitle: const Text('Enregistrement de la réunion'),
              onTap: () {
                Navigator.pop(context);
                _downloadAudio();
              },
            ),
            
            // Télécharger les deux
            ListTile(
              leading: const Icon(Icons.folder_zip, color: Colors.orange),
              title: const Text('Transcription + Audio'),
              subtitle: const Text('Tout télécharger'),
              onTap: () {
                Navigator.pop(context);
                _downloadBoth();
              },
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Télécharger la transcription en PDF
  Future<void> _downloadTranscript() async {
    try {
      final segments = MockData.getSegments(widget.meetingId);
      
      // Créer le document PDF
      final pdf = pw.Document();
      
      // Ajouter une page
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              // En-tête
              pw.Header(
                level: 0,
                child: pw.Text(
                  'TRANSCRIPTION DE RÉUNION',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              
              // Segments
              ...segments.map((segment) {
                final speaker = segment['speakerName'] as String? ?? 'Inconnu';
                final text = _editedTexts[segment['id']] ?? segment['text'] as String;
                final startTime = segment['startTime'] as double;
                final endTime = segment['endTime'] as double;
                final confidence = segment['confidence'] as double;
                
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // En-tête du segment
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            speaker,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue800,
                            ),
                          ),
                          pw.Text(
                            '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      
                      // Texte
                      pw.Text(
                        text,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          lineSpacing: 1.5,
                        ),
                      ),
                      
                      // Badge de confiance
                      pw.SizedBox(height: 6),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: pw.BoxDecoration(
                              color: _getConfidenceColor(confidence),
                              borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4),
                              ),
                            ),
                            child: pw.Text(
                              'Confiance: ${(confidence * 100).toStringAsFixed(0)}%',
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Pied de page
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Document généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} à ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ];
          },
        ),
      );
      
      // Sauvegarder et partager le PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/transcription_${widget.meetingId}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Transcription de réunion',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF généré et partagé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
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
  
  /// Obtenir la couleur selon le niveau de confiance
  PdfColor _getConfidenceColor(double confidence) {
    if (confidence >= 0.95) {
      return PdfColors.green;
    } else if (confidence >= 0.90) {
      return PdfColors.lightGreen;
    } else if (confidence >= 0.85) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
  }
  
  /// Télécharger l'audio
  Future<void> _downloadAudio() async {
    try {
      // Pour l'instant, on partage juste l'info que l'audio existe
      // Dans une vraie app, on copierait le fichier audio
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio disponible dans assets/audio/audio.mp3'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
  
  /// Télécharger les deux
  Future<void> _downloadBoth() async {
    await _downloadTranscript();
    await _downloadAudio();
  }

  /// Card pour un segment de transcription
  Widget _buildSegmentCard(Map<String, dynamic> segment) {
    final segmentId = segment['id'] as String;
    final speakerName = segment['speakerName'] as String? ?? 
                       'Participant ${segment['speakerId']}';
    final originalText = segment['text'] as String;
    final displayText = _editedTexts[segmentId] ?? originalText;
    final startTime = segment['startTime'] as double;
    final endTime = segment['endTime'] as double;
    final confidence = segment['confidence'] as double;
    final isEdited = _editedTexts.containsKey(segmentId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditDialog(segmentId, speakerName, displayText),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec speaker et timestamp
              Row(
                children: [
                  // Avatar du speaker
                  CircleAvatar(
                    radius: 20,
                    child: Text(
                      speakerName.isNotEmpty ? speakerName[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Nom du speaker
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speakerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Badge de confiance
                  _buildConfidenceBadge(confidence),
                  
                  // Icône d'édition si modifié
                  if (isEdited) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.edit, size: 16, color: Colors.blue),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Texte de la transcription
              Text(
                displayText,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isEdited ? Colors.blue[900] : Colors.black,
                  fontStyle: isEdited ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              
              // Indication de clic pour éditer
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Cliquer pour éditer',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Afficher le dialogue d'édition
  void _showEditDialog(String segmentId, String speakerName, String currentText) {
    final controller = TextEditingController(text: currentText);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Éditer - $speakerName',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Modifiez le texte de la transcription...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          if (_editedTexts.containsKey(segmentId))
            TextButton(
              onPressed: () {
                setState(() {
                  _editedTexts.remove(segmentId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Texte restauré'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Restaurer'),
            ),
          FilledButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty && newText != currentText) {
                setState(() {
                  _editedTexts[segmentId] = newText;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Texte modifié avec succès'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  /// Badge de confiance de la transcription
  Widget _buildConfidenceBadge(double confidence) {
    Color color;
    String label;

    if (confidence >= 0.95) {
      color = Colors.green;
      label = 'Excellent';
    } else if (confidence >= 0.90) {
      color = Colors.lightGreen;
      label = 'Très bon';
    } else if (confidence >= 0.85) {
      color = Colors.orange;
      label = 'Bon';
    } else {
      color = Colors.red;
      label = 'Moyen';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Formater le temps en MM:SS
  String _formatTime(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  /// Formater une durée en HH:MM:SS ou MM:SS
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
