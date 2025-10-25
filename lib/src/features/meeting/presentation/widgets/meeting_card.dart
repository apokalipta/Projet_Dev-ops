import 'package:flutter/material.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MeetingCard({
    super.key,
    required this.meeting,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(meeting.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${meeting.participants.length} participant${meeting.participants.length > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (meeting.duration != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      '${meeting.duration} min',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              _buildStatusChip(meeting.status),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(MeetingStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case MeetingStatus.scheduled:
        color = Colors.blue;
        label = 'Planifiée';
        icon = Icons.schedule;
        break;
      case MeetingStatus.inProgress:
        color = Colors.orange;
        label = 'En cours';
        icon = Icons.play_circle;
        break;
      case MeetingStatus.completed:
        color = Colors.green;
        label = 'Terminée';
        icon = Icons.check_circle;
        break;
      case MeetingStatus.transcribed:
        color = Colors.purple;
        label = 'Transcrite';
        icon = Icons.text_snippet;
        break;
      case MeetingStatus.failed:
        color = Colors.red;
        label = 'Échec';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Aujourd\'hui à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Demain à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference == -1) {
      return 'Hier à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
