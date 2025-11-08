# 🔌 Guide d'intégration des données mockées dans l'app existante

## 🎯 Objectif

Intégrer le système de données mockées dans votre application Flutter existante pour pouvoir développer avec des données réalistes sans backend.

---

## ✅ Étape 1 : Vérifier les fichiers créés

Assurez-vous que ces fichiers existent :

```
lib/src/core/
├── config/
│   └── app_config.dart                 ✅
├── data/
│   ├── mock_data.dart                  ✅
│   ├── mock_api_service.dart           ✅
│   ├── mock_api_service.g.dart         ✅ (généré)
│   ├── api_service_provider.dart       ✅
│   └── api_service_provider.g.dart     ✅ (généré)
```

---

## 🔧 Étape 2 : Activer le mode Mock

Éditez `lib/src/core/config/app_config.dart` :

```dart
class AppConfig {
  static const bool useMockData = true; // ✅ ACTIVÉ
}
```

---

## 📱 Étape 3 : Modifier votre écran de liste de réunions

### Avant (avec données mockées locales)

```dart
// lib/src/features/meeting/presentation/screens/meetings_list_screen.dart

class MeetingsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Données en dur
    final meetings = [
      {'title': 'Réunion 1', 'date': '2024-11-07'},
      {'title': 'Réunion 2', 'date': '2024-11-08'},
    ];
    
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return ListTile(
          title: Text(meeting['title']),
          subtitle: Text(meeting['date']),
        );
      },
    );
  }
}
```

### Après (avec le système de mock)

```dart
// lib/src/features/meeting/presentation/screens/meetings_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/api_service_provider.dart';

class MeetingsListScreen extends ConsumerWidget {
  const MeetingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utilise automatiquement Mock ou Real selon AppConfig
    final meetingService = ref.watch(meetingServiceProvider);

    return FutureBuilder(
      future: meetingService.getAllMeetings(),
      builder: (context, snapshot) {
        // Gestion du chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Gestion des erreurs
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Rafraîchir
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        // Affichage des données
        final response = snapshot.data!;
        final meetings = response.data as List;

        if (meetings.isEmpty) {
          return const Center(
            child: Text('Aucune réunion'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Rafraîchir les données
          },
          child: ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(meeting['title'] as String),
                  subtitle: Text(
                    '${meeting['date']} - ${(meeting['duration'] as int) ~/ 60} min',
                  ),
                  trailing: _buildStatusChip(meeting['status'] as String),
                  onTap: () {
                    // Navigation vers les détails
                    Navigator.pushNamed(
                      context,
                      '/meeting-details',
                      arguments: meeting['id'],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status == 'completed' ? 'Terminée' : 'Planifiée',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: status == 'completed' ? Colors.green : Colors.orange,
    );
  }
}
```

---

## 📄 Étape 4 : Créer l'écran de détails

Créez `lib/src/features/meeting/presentation/screens/meeting_details_screen.dart` :

```dart
import 'package:flutter/material.dart';
import '../../../../core/data/mock_data.dart';

class MeetingDetailsScreen extends StatelessWidget {
  final String meetingId;

  const MeetingDetailsScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final meeting = MockData.getMeetingById(meetingId);
    final synthesis = MockData.getMeetingSynthesis(meetingId);

    if (meeting == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Réunion non trouvée')),
      );
    }

    final participants = synthesis['participants'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting['title'] as String),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              meeting['description'] as String? ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Statistiques
            _buildStatsCard(synthesis),
            const SizedBox(height: 24),

            // Participants
            const Text(
              'Participants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...participants.map((p) => _buildParticipantCard(p)).toList(),
            
            const SizedBox(height: 24),

            // Bouton transcription
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/transcription',
                    arguments: meetingId,
                  );
                },
                icon: const Icon(Icons.mic),
                label: const Text('Voir la transcription'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic> synthesis) {
    final totalDuration = synthesis['totalDuration'] as int;
    final totalSpeakTime = synthesis['totalSpeakTime'] as int;
    final silenceTime = synthesis['silenceTime'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              'Durée totale',
              '${totalDuration ~/ 60} min',
              Icons.access_time,
            ),
            const Divider(),
            _buildStatRow(
              'Temps de parole',
              '${totalSpeakTime ~/ 60} min',
              Icons.record_voice_over,
            ),
            const Divider(),
            _buildStatRow(
              'Temps de silence',
              '${silenceTime ~/ 60} min',
              Icons.volume_off,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Map<String, dynamic> participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(participant['avatar'] as String),
        ),
        title: Text(participant['name'] as String),
        subtitle: Text(participant['role'] as String),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(participant['speakTime'] as int) ~/ 60} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${participant['speakPercentage']}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎤 Étape 5 : Créer l'écran de transcription

Créez `lib/src/features/meeting/presentation/screens/transcription_screen.dart` :

```dart
import 'package:flutter/material.dart';
import '../../../../core/data/mock_data.dart';

class TranscriptionScreen extends StatelessWidget {
  final String meetingId;

  const TranscriptionScreen({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    final meeting = MockData.getMeetingById(meetingId);
    final segments = MockData.getSegments(meetingId);

    return Scaffold(
      appBar: AppBar(
        title: Text(meeting?['title'] ?? 'Transcription'),
      ),
      body: segments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune transcription disponible'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: segments.length,
              itemBuilder: (context, index) {
                final segment = segments[index];
                final speaker = MockData.getParticipantById(
                  segment['speakerId'] as String,
                );

                return _buildSegmentCard(segment, speaker);
              },
            ),
    );
  }

  Widget _buildSegmentCard(
    Map<String, dynamic> segment,
    Map<String, dynamic>? speaker,
  ) {
    final confidence = segment['confidence'] as double;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec locuteur
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(speaker?['avatar'] ?? ''),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        speaker?['name'] ?? 'Inconnu',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        speaker?['role'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(segment['startTime'] as double).toStringAsFixed(1)}s',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Texte transcrit
            Text(
              segment['text'] as String,
              style: const TextStyle(fontSize: 15, height: 1.5),
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
          ],
        ),
      ),
    );
  }
}
```

---

## 🗺️ Étape 6 : Mettre à jour les routes

Éditez votre fichier de routes (probablement `lib/src/core/navigation/app_router.dart`) :

```dart
import 'package:go_router/go_router.dart';
import '../../features/meeting/presentation/screens/meetings_list_screen.dart';
import '../../features/meeting/presentation/screens/meeting_details_screen.dart';
import '../../features/meeting/presentation/screens/transcription_screen.dart';

final router = GoRouter(
  routes: [
    // ... autres routes
    
    GoRoute(
      path: '/meetings',
      builder: (context, state) => const MeetingsListScreen(),
    ),
    
    GoRoute(
      path: '/meeting-details/:id',
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return MeetingDetailsScreen(meetingId: meetingId);
      },
    ),
    
    GoRoute(
      path: '/transcription/:id',
      builder: (context, state) {
        final meetingId = state.pathParameters['id']!;
        return TranscriptionScreen(meetingId: meetingId);
      },
    ),
  ],
);
```

---

## 🎨 Étape 7 : Tester l'application

1. **Lancer l'app** :
   ```bash
   flutter run
   ```

2. **Vérifier la configuration** :
   - Les données mockées doivent s'afficher
   - Vous devriez voir 6 réunions
   - Le délai de chargement simule la latence réseau (500ms)

3. **Tester les fonctionnalités** :
   - ✅ Liste des réunions
   - ✅ Détails d'une réunion
   - ✅ Liste des participants
   - ✅ Statistiques
   - ✅ Transcription

---

## 🔄 Étape 8 : Passer en mode production (plus tard)

Quand votre backend sera prêt :

1. **Configurer l'URL** dans `lib/src/core/api/api_config.dart` :
   ```dart
   static const String devUrl = 'http://votre-backend-url:8080/api';
   ```

2. **Désactiver le mode Mock** dans `lib/src/core/config/app_config.dart` :
   ```dart
   static const bool useMockData = false; // ❌ DÉSACTIVÉ
   ```

3. **Tester** :
   - Relancer l'app
   - Vérifier que les vraies APIs fonctionnent
   - Gérer les erreurs réelles

---

## 📊 Étape 9 : Ajouter des statistiques globales (Bonus)

Créez un widget pour afficher les statistiques :

```dart
// lib/src/features/home/presentation/widgets/stats_widget.dart

import 'package:flutter/material.dart';
import '../../../../core/data/mock_data.dart';

class StatsWidget extends StatelessWidget {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockData.getGlobalStats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatItem(
              'Total réunions',
              '${stats['totalMeetings']}',
              Icons.event,
            ),
            _buildStatItem(
              'Réunions terminées',
              '${stats['completedMeetings']}',
              Icons.check_circle,
            ),
            _buildStatItem(
              'Réunions planifiées',
              '${stats['scheduledMeetings']}',
              Icons.schedule,
            ),
            _buildStatItem(
              'Durée totale',
              '${(stats['totalDuration'] as int) ~/ 3600}h',
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ Checklist finale

- [ ] Fichiers mockés créés et générés
- [ ] `useMockData = true` dans `app_config.dart`
- [ ] Écran de liste des réunions modifié
- [ ] Écran de détails créé
- [ ] Écran de transcription créé
- [ ] Routes configurées
- [ ] Application testée
- [ ] Données mockées s'affichent correctement

---

## 🎉 Résultat

Vous avez maintenant une application fonctionnelle avec :

✅ **6 réunions** mockées réalistes  
✅ **6 participants** avec avatars  
✅ **Transcriptions** avec segments  
✅ **Statistiques** complètes  
✅ **Navigation** entre les écrans  
✅ **Gestion des erreurs**  
✅ **Simulation de latence réseau**  

Vous pouvez développer toute votre UI sans attendre le backend ! 🚀

---

**Prochaine étape** : Développer les autres fonctionnalités (recherche, création de réunion, etc.)
