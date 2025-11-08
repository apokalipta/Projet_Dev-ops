# 🎭 Guide d'utilisation des données mockées

## 📋 Vue d'ensemble

Ce système permet de développer l'application avec des données réalistes **sans avoir besoin d'un backend fonctionnel**.

## 🎯 Activation/Désactivation

### Activer les données mockées (Mode développement)

Éditez `lib/src/core/config/app_config.dart` :

```dart
class AppConfig {
  static const bool useMockData = true; // ✅ Mode Mock activé
}
```

### Désactiver les données mockées (Mode production)

```dart
class AppConfig {
  static const bool useMockData = false; // ❌ Mode Mock désactivé
}
```

## 📊 Données disponibles

### Réunions (6 réunions)

| ID | Titre | Status | Participants | Durée |
|----|-------|--------|--------------|-------|
| meeting-001 | Sprint Planning | completed | 4 | 1h |
| meeting-002 | Revue de code Backend | completed | 3 | 1h30 |
| meeting-003 | Présentation Client | completed | 3 | 45min |
| meeting-004 | Daily Standup | scheduled | - | 15min |
| meeting-005 | Rétrospective Sprint | completed | 4 | 1h15 |
| meeting-006 | Formation Flutter | scheduled | - | 2h |

### Participants (6 personnes)

| ID | Nom | Rôle |
|----|-----|------|
| participant-001 | Alice Dupont | Tech Lead |
| participant-002 | Bob Martin | Développeur Backend |
| participant-003 | Claire Leroy | Développeuse Frontend |
| participant-004 | David Chen | Product Owner |
| participant-005 | Emma Wilson | UX Designer |
| participant-006 | François Dubois | Scrum Master |

### Segments de transcription

- **meeting-001** : 5 segments de conversation
- **meeting-002** : 3 segments de conversation

Chaque segment contient :
- Texte transcrit
- Locuteur (participant)
- Temps de début/fin
- Score de confiance (0-1)

## 🚀 Utilisation

### Méthode 1 : Via les providers (Recommandé)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:votre_app/src/core/data/api_service_provider.dart';

class MeetingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Le provider retourne automatiquement Mock ou Real selon AppConfig
    final meetingService = ref.watch(meetingServiceProvider);
    
    return FutureBuilder(
      future: meetingService.getAllMeetings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final meetings = snapshot.data!.data;
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
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Méthode 2 : Accès direct aux données

```dart
import 'package:votre_app/src/core/data/mock_data.dart';

// Obtenir toutes les réunions
final meetings = MockData.meetings;

// Obtenir une réunion spécifique
final meeting = MockData.getMeetingById('meeting-001');

// Obtenir les participants d'une réunion
final participants = MockData.getMeetingParticipantsList('meeting-001');

// Obtenir les segments de transcription
final segments = MockData.getSegments('meeting-001');

// Obtenir la synthèse d'une réunion
final synthesis = MockData.getMeetingSynthesis('meeting-001');

// Obtenir les statistiques globales
final stats = MockData.getGlobalStats();

// Rechercher des réunions
final results = MockData.searchMeetings('sprint');
```

### Méthode 3 : Via MockApiService

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:votre_app/src/core/data/mock_api_service.dart';

class MeetingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockService = ref.watch(mockApiServiceProvider);
    
    return FutureBuilder(
      future: mockService.getAllMeetings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final response = snapshot.data!;
          final meetings = response.data;
          // Utiliser les données...
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 🎨 Exemples d'utilisation

### Exemple 1 : Afficher la liste des réunions

```dart
class MeetingListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final meetings = MockData.meetings;
    
    return ListView.builder(
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final meeting = meetings[index];
        return Card(
          child: ListTile(
            title: Text(meeting['title']),
            subtitle: Text(
              '${meeting['date']} - ${meeting['duration'] ~/ 60} min',
            ),
            trailing: Chip(
              label: Text(meeting['status']),
              backgroundColor: meeting['status'] == 'completed'
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
        );
      },
    );
  }
}
```

### Exemple 2 : Afficher les participants avec statistiques

```dart
class ParticipantsWidget extends StatelessWidget {
  final String meetingId;
  
  ParticipantsWidget({required this.meetingId});
  
  @override
  Widget build(BuildContext context) {
    final synthesis = MockData.getMeetingSynthesis(meetingId);
    final participants = synthesis['participants'] as List;
    
    return ListView.builder(
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(participant['avatar']),
          ),
          title: Text(participant['name']),
          subtitle: Text(participant['role']),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${participant['speakTime'] ~/ 60} min'),
              Text(
                '${participant['speakPercentage']}%',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Exemple 3 : Afficher la transcription

```dart
class TranscriptionWidget extends StatelessWidget {
  final String meetingId;
  
  TranscriptionWidget({required this.meetingId});
  
  @override
  Widget build(BuildContext context) {
    final segments = MockData.getSegments(meetingId);
    
    return ListView.builder(
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        final speaker = MockData.getParticipantById(segment['speakerId']);
        
        return Card(
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(speaker?['avatar'] ?? ''),
                      radius: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      speaker?['name'] ?? 'Inconnu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                      '${segment['startTime'].toStringAsFixed(1)}s',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(segment['text']),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: segment['confidence'],
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    segment['confidence'] > 0.9 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

### Exemple 4 : Créer une nouvelle réunion

```dart
Future<void> createNewMeeting(WidgetRef ref) async {
  final meetingService = ref.read(meetingServiceProvider);
  
  final newMeeting = {
    'title': 'Nouvelle réunion',
    'description': 'Description de la réunion',
    'date': DateTime.now().toIso8601String(),
    'duration': 3600,
    'language': 'FR',
    'location': 'Salle A',
  };
  
  try {
    final response = await meetingService.createMeeting(newMeeting);
    print('Réunion créée: ${response.data}');
  } catch (e) {
    print('Erreur: $e');
  }
}
```

### Exemple 5 : Rechercher des réunions

```dart
class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  List<Map<String, dynamic>> results = [];
  
  void _search(String query) {
    setState(() {
      results = MockData.searchMeetings(query);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Rechercher une réunion...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final meeting = results[index];
              return ListTile(
                title: Text(meeting['title']),
                subtitle: Text(meeting['description'] ?? ''),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 🔧 Configuration avancée

### Modifier le délai réseau simulé

```dart
// Dans app_config.dart
static const int mockNetworkDelay = 500; // millisecondes

// Ou directement dans MockApiService
final mockService = MockApiService(networkDelay: 1000); // 1 seconde
```

### Ajouter de nouvelles données

Éditez `lib/src/core/data/mock_data.dart` :

```dart
static final List<Map<String, dynamic>> meetings = [
  // ... données existantes
  {
    'id': 'meeting-007',
    'title': 'Ma nouvelle réunion',
    'description': 'Description',
    'date': '2024-11-15T10:00:00Z',
    'duration': 3600,
    'status': 'scheduled',
    'language': 'FR',
    'location': 'Salle C',
    'createdAt': '2024-11-10T09:00:00Z',
    'updatedAt': '2024-11-10T09:00:00Z',
  },
];
```

## 📈 Statistiques disponibles

```dart
final stats = MockData.getGlobalStats();

print('Total réunions: ${stats['totalMeetings']}');
print('Réunions terminées: ${stats['completedMeetings']}');
print('Réunions planifiées: ${stats['scheduledMeetings']}');
print('Durée totale: ${stats['totalDuration']} secondes');
print('Durée moyenne: ${stats['averageDuration']} secondes');
print('Total participants: ${stats['totalParticipants']}');
```

## 🎯 Synthèse d'une réunion

```dart
final synthesis = MockData.getMeetingSynthesis('meeting-001');

print('Titre: ${synthesis['title']}');
print('Durée totale: ${synthesis['totalDuration']}s');
print('Temps de parole: ${synthesis['totalSpeakTime']}s');
print('Temps de silence: ${synthesis['silenceTime']}s');
print('Nombre de participants: ${synthesis['participantCount']}');

// Détails des participants
for (var participant in synthesis['participants']) {
  print('${participant['name']}: ${participant['speakTime']}s (${participant['speakPercentage']}%)');
}
```

## ⚠️ Important

### Limitations du mode Mock

- Les données sont **en mémoire** : elles sont perdues au redémarrage de l'app
- Les fichiers audio sont **simulés** (bytes vides)
- Pas de **validation** côté serveur
- Pas de **persistance** automatique

### Passer en mode production

1. Configurez l'URL du backend dans `api_config.dart`
2. Changez `useMockData` à `false` dans `app_config.dart`
3. Testez tous les endpoints avec le vrai backend
4. Vérifiez la gestion des erreurs

## 🔄 Workflow recommandé

1. **Développement initial** : `useMockData = true`
   - Développer l'UI
   - Tester les flux utilisateur
   - Valider les designs

2. **Intégration backend** : `useMockData = false`
   - Connecter au vrai backend
   - Tester les vraies APIs
   - Gérer les erreurs réelles

3. **Tests** : Alterner entre les deux modes
   - Tests unitaires avec mock
   - Tests d'intégration avec API réelle

## 📝 Checklist

- [ ] Activer `useMockData = true` dans `app_config.dart`
- [ ] Importer `api_service_provider.dart` dans vos widgets
- [ ] Utiliser `meetingServiceProvider` ou `transcriptionServiceProvider`
- [ ] Tester l'affichage avec les données mockées
- [ ] Développer toutes les fonctionnalités
- [ ] Passer en mode production (`useMockData = false`)
- [ ] Tester avec le vrai backend

---

**Astuce** : Utilisez `AppConfig.getConfigInfo()` pour afficher la configuration actuelle dans la console au démarrage de l'app.
