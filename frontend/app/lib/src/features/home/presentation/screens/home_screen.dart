import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:meeting_app/src/features/meeting/domain/entities/meeting.dart';
import 'package:meeting_app/src/features/meeting/presentation/providers/meeting_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final meetingsAsync = ref.watch(asyncMeetingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/create-meeting'),
            tooltip: 'Créer une réunion',
          ),
        ],
      ),
      body: meetingsAsync.when(
        data: (meetings) {
          final upcomingMeetings = meetings
              .where((m) => m.status == MeetingStatus.scheduled)
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
          
          final recentMeetings = meetings
              .where((m) => m.status == MeetingStatus.completed || m.status == MeetingStatus.transcribed)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(asyncMeetingProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // En-tête de bienvenue
                Text(
                  'Bonjour !',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Voici un résumé de vos réunions',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Statistiques
                _buildStatsCards(meetings),
                const SizedBox(height: 24),

                // Prochaines réunions
                if (upcomingMeetings.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prochaines réunions',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/meetings'),
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final meeting in upcomingMeetings.take(3))
                    _buildMeetingCard(context, meeting, true),
                  const SizedBox(height: 24),
                ],

                // Réunions récentes
                if (recentMeetings.isNotEmpty) ...[
                  Text(
                    'Réunions récentes',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final meeting in recentMeetings.take(3))
                    _buildMeetingCard(context, meeting, false),
                ],

                // Message si aucune réunion
                if (meetings.isEmpty) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune réunion',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Créez votre première réunion',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push('/create-meeting'),
                          icon: const Icon(Icons.add),
                          label: const Text('Créer une réunion'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(asyncMeetingProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(List<Meeting> meetings) {
    final scheduled = meetings.where((m) => m.status == MeetingStatus.scheduled).length;
    final completed = meetings.where((m) => m.status == MeetingStatus.completed || m.status == MeetingStatus.transcribed).length;
    final total = meetings.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_available,
            label: 'Planifiées',
            value: scheduled.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Terminées',
            value: completed.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.event_note,
            label: 'Total',
            value: total.toString(),
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(BuildContext context, Meeting meeting, bool isUpcoming) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to meeting details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUpcoming ? Colors.blue.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isUpcoming ? Icons.schedule : Icons.check_circle,
                      color: isUpcoming ? Colors.blue : Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dateFormat.format(meeting.date)} à ${timeFormat.format(meeting.date)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (meeting.description != null && meeting.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  meeting.description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.participants.length} participants',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${meeting.duration ?? 0} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
}
