import 'package:flutter/material.dart';
import '../../../../core/data/mock_data.dart';

/// Écran d'affichage de la transcription d'une réunion
class MeetingTranscriptScreen extends StatelessWidget {
  final String meetingId;

  const MeetingTranscriptScreen({
    super.key,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context) {
    final segments = MockData.getSegments(meetingId);

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
      appBar: AppBar(
        title: const Text('Transcription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche dans la transcription
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // TODO: Implémenter l'export de la transcription
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: segments.length,
        itemBuilder: (context, index) {
          final segment = segments[index];
          return _buildSegmentCard(segment);
        },
      ),
    );
  }

  /// Card pour un segment de transcription
  Widget _buildSegmentCard(Map<String, dynamic> segment) {
    final speakerName = segment['speakerName'] as String? ?? 
                       'Participant ${segment['speakerId']}';
    final text = segment['text'] as String;
    final startTime = segment['startTime'] as double;
    final endTime = segment['endTime'] as double;
    final confidence = segment['confidence'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Texte de la transcription
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
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
}
