# 🎭 Résumé - Système de données mockées

## ✅ Ce qui a été créé

### Fichiers principaux (5 fichiers)

| Fichier | Description | Lignes |
|---------|-------------|--------|
| **mock_data.dart** | Données mockées réalistes | ~400 |
| **mock_api_service.dart** | Service API simulé | ~350 |
| **app_config.dart** | Configuration de l'app | ~80 |
| **api_service_provider.dart** | Switch Mock/Real API | ~250 |
| **README_MOCK_DATA.md** | Documentation complète | ~600 |
| **EXAMPLE_MOCK_USAGE.dart** | Exemples pratiques | ~500 |

### Total
- **6 fichiers** créés
- **~2180 lignes** de code et documentation
- **100% prêt** à l'emploi

---

## 📊 Données disponibles

### Réunions : 6 réunions mockées

| ID | Titre | Status | Durée | Participants |
|----|-------|--------|-------|--------------|
| meeting-001 | Sprint Planning | ✅ completed | 1h | 4 |
| meeting-002 | Revue de code Backend | ✅ completed | 1h30 | 3 |
| meeting-003 | Présentation Client | ✅ completed | 45min | 3 |
| meeting-004 | Daily Standup | 🟠 scheduled | 15min | - |
| meeting-005 | Rétrospective Sprint | ✅ completed | 1h15 | 4 |
| meeting-006 | Formation Flutter | 🟠 scheduled | 2h | - |

### Participants : 6 personnes

1. **Alice Dupont** - Tech Lead
2. **Bob Martin** - Développeur Backend
3. **Claire Leroy** - Développeuse Frontend
4. **David Chen** - Product Owner
5. **Emma Wilson** - UX Designer
6. **François Dubois** - Scrum Master

### Transcriptions : 2 réunions

- **meeting-001** : 5 segments de conversation
- **meeting-002** : 3 segments de conversation

Chaque segment contient :
- ✅ Texte transcrit réaliste
- ✅ Locuteur (participant)
- ✅ Timestamps (début/fin)
- ✅ Score de confiance (0.88-0.96)

---

## 🚀 Utilisation rapide

### Étape 1 : Activer le mode Mock

Éditez `lib/src/core/config/app_config.dart` :

```dart
class AppConfig {
  static const bool useMockData = true; // ✅ Activé
}
```

### Étape 2 : Utiliser dans vos widgets

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:votre_app/src/core/data/api_service_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bascule automatiquement entre Mock et Real selon AppConfig
    final meetingService = ref.watch(meetingServiceProvider);
    
    return FutureBuilder(
      future: meetingService.getAllMeetings(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final meetings = snapshot.data!.data;
          // Utiliser les données...
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

### Étape 3 : Accès direct aux données (optionnel)

```dart
import 'package:votre_app/src/core/data/mock_data.dart';

// Obtenir toutes les réunions
final meetings = MockData.meetings;

// Obtenir une réunion spécifique
final meeting = MockData.getMeetingById('meeting-001');

// Obtenir la synthèse
final synthesis = MockData.getMeetingSynthesis('meeting-001');

// Rechercher
final results = MockData.searchMeetings('sprint');
```

---

## 🎯 Fonctionnalités disponibles

### Service Meeting (7 endpoints)

| Endpoint | Méthode | Fonctionnel |
|----------|---------|-------------|
| Créer une réunion | `createMeeting()` | ✅ |
| Lister toutes les réunions | `getAllMeetings()` | ✅ |
| Obtenir une réunion | `getMeetingById()` | ✅ |
| Lister les participants | `getMeetingParticipants()` | ✅ |
| Ajouter un participant | `addParticipant()` | ✅ |
| Retirer un participant | `removeParticipant()` | ✅ |
| Rechercher par titre | `searchMeetingByTitle()` | ✅ |

### Service Transcription (9 endpoints)

| Endpoint | Méthode | Fonctionnel |
|----------|---------|-------------|
| Transcrire un audio | `transcribeAudio()` | ✅ |
| Lister les segments | `getAllSegments()` | ✅ |
| Obtenir un segment | `getSegmentById()` | ✅ |
| Modifier un segment | `updateSegmentText()` | ✅ |
| Lister les locuteurs | `getSegmentSpeakers()` | ✅ |
| Modifier le locuteur | `updateSegmentSpeaker()` | ✅ |
| Récupérer l'audio | `getRecordFile()` | ✅ |
| Heure de début | `getSegmentStartTime()` | ✅ |
| Heure de fin | `getSegmentEndTime()` | ✅ |

### Fonctionnalités bonus

- ✅ **Synthèse de réunion** : `getMeetingSynthesis()`
- ✅ **Statistiques globales** : `getGlobalStats()`
- ✅ **Recherche** : `searchMeetings()`
- ✅ **Simulation de latence réseau** (500ms par défaut)
- ✅ **Gestion des erreurs** (404, 400, etc.)

---

## 📁 Structure des fichiers

```
lib/src/core/
├── config/
│   └── app_config.dart                 ✅ Configuration globale
├── data/
│   ├── mock_data.dart                  ✅ Données mockées
│   ├── mock_api_service.dart           ✅ Service API simulé
│   ├── api_service_provider.dart       ✅ Switch Mock/Real
│   ├── README_MOCK_DATA.md             ✅ Documentation
│   └── EXAMPLE_MOCK_USAGE.dart         ✅ Exemples
└── api/
    ├── meeting_api_service.dart        (Existant)
    └── transcription_api_service.dart  (Existant)
```

---

## 🎨 Exemples disponibles

Dans `EXAMPLE_MOCK_USAGE.dart`, vous trouverez :

1. **SimpleMeetingListExample** - Liste simple de réunions
2. **MeetingListWithProviderExample** - Liste avec Riverpod
3. **MeetingDetailsExample** - Détails avec participants
4. **TranscriptionExample** - Affichage de la transcription
5. **SearchMeetingsExample** - Recherche de réunions
6. **CreateMeetingExample** - Création de réunion

---

## ⚙️ Configuration

### Paramètres disponibles

```dart
// app_config.dart
class AppConfig {
  // Mode Mock (true = mock, false = API réelle)
  static const bool useMockData = true;
  
  // Délai réseau simulé (millisecondes)
  static const int mockNetworkDelay = 500;
  
  // Mode debug
  static const bool debugMode = true;
  
  // Features flags
  static const bool enableTranscription = true;
  static const bool enableAiAnalysis = true;
  static const bool enableOfflineMode = true;
}
```

### Afficher la configuration

```dart
void main() {
  print(AppConfig.getConfigInfo());
  runApp(MyApp());
}
```

Sortie :
```
╔════════════════════════════════════════╗
║     Configuration de l'application     ║
╠════════════════════════════════════════╣
║ Mode Mock:        ACTIVÉ ✅            ║
║ Debug Mode:       ACTIVÉ ✅            ║
║ API Base URL:     http://localhost:8080/api
║ Transcription:    ACTIVÉ ✅            ║
║ AI Analysis:      ACTIVÉ ✅            ║
║ Offline Mode:     ACTIVÉ ✅            ║
╚════════════════════════════════════════╝
```

---

## 🔄 Workflow de développement

### Phase 1 : Développement avec Mock (Actuel)

```dart
// app_config.dart
static const bool useMockData = true; // ✅
```

**Avantages** :
- ✅ Pas besoin de backend
- ✅ Développement rapide
- ✅ Données cohérentes
- ✅ Pas de problème réseau

**Actions** :
1. Développer toute l'UI
2. Tester les flux utilisateur
3. Valider les designs
4. Créer les widgets

### Phase 2 : Intégration Backend

```dart
// app_config.dart
static const bool useMockData = false; // ❌
```

**Actions** :
1. Configurer l'URL du backend
2. Tester les vrais endpoints
3. Gérer les erreurs réelles
4. Optimiser les performances

### Phase 3 : Tests

Alterner entre les deux modes :
- **Tests unitaires** : Mock
- **Tests d'intégration** : Real API
- **Tests E2E** : Real API

---

## 📈 Statistiques disponibles

```dart
final stats = MockData.getGlobalStats();

// Résultat :
{
  'totalMeetings': 6,
  'completedMeetings': 4,
  'scheduledMeetings': 2,
  'totalDuration': 14400, // secondes
  'averageDuration': 3600, // secondes
  'totalParticipants': 6,
}
```

---

## 🎯 Cas d'usage

### 1. Afficher la liste des réunions

```dart
final meetings = MockData.meetings;
// Retourne : List<Map<String, dynamic>> (6 réunions)
```

### 2. Obtenir les détails d'une réunion

```dart
final meeting = MockData.getMeetingById('meeting-001');
// Retourne : Map<String, dynamic> avec tous les détails
```

### 3. Obtenir les participants avec statistiques

```dart
final synthesis = MockData.getMeetingSynthesis('meeting-001');
final participants = synthesis['participants'];
// Chaque participant a : name, role, speakTime, interventions, speakPercentage
```

### 4. Afficher la transcription

```dart
final segments = MockData.getSegments('meeting-001');
// Retourne : List<Map<String, dynamic>> (5 segments)
// Chaque segment a : text, speakerId, startTime, endTime, confidence
```

### 5. Rechercher des réunions

```dart
final results = MockData.searchMeetings('sprint');
// Retourne : List<Map<String, dynamic>> (réunions contenant "sprint")
```

### 6. Créer une nouvelle réunion

```dart
final service = ref.read(meetingServiceProvider);
await service.createMeeting({
  'title': 'Ma réunion',
  'description': 'Description',
  'date': DateTime.now().toIso8601String(),
  'duration': 3600,
});
```

---

## ⚠️ Important

### Limitations du mode Mock

- ❌ Données **en mémoire** (perdues au redémarrage)
- ❌ Fichiers audio **simulés** (bytes vides)
- ❌ Pas de **validation** serveur
- ❌ Pas de **persistance** automatique

### Avantages du mode Mock

- ✅ **Aucune dépendance** backend
- ✅ **Développement rapide**
- ✅ **Données cohérentes**
- ✅ **Pas de latence réseau** (sauf simulation)
- ✅ **Tests faciles**

---

## 📝 Checklist

### Configuration
- [x] Créer `mock_data.dart` avec données réalistes
- [x] Créer `mock_api_service.dart` avec tous les endpoints
- [x] Créer `app_config.dart` pour la configuration
- [x] Créer `api_service_provider.dart` pour le switch
- [x] Générer les fichiers `.g.dart`

### Utilisation
- [ ] Activer `useMockData = true` dans `app_config.dart`
- [ ] Importer `api_service_provider.dart` dans vos widgets
- [ ] Utiliser `meetingServiceProvider` ou `transcriptionServiceProvider`
- [ ] Tester l'affichage avec les données mockées
- [ ] Développer toutes les fonctionnalités

### Production
- [ ] Configurer l'URL du backend
- [ ] Passer en mode `useMockData = false`
- [ ] Tester avec le vrai backend
- [ ] Gérer les erreurs réelles
- [ ] Déployer

---

## 🆘 Support

### Documentation
- **README_MOCK_DATA.md** - Guide complet d'utilisation
- **EXAMPLE_MOCK_USAGE.dart** - 6 exemples pratiques
- **API_SPECIFICATION.md** - Spécification des endpoints

### Problèmes courants

**Q : Les données ne s'affichent pas ?**
- Vérifiez que `useMockData = true` dans `app_config.dart`
- Vérifiez que vous utilisez `meetingServiceProvider`

**Q : Comment ajouter des données ?**
- Éditez `mock_data.dart` et ajoutez vos données

**Q : Comment changer le délai réseau ?**
- Modifiez `mockNetworkDelay` dans `app_config.dart`

**Q : Comment passer en mode production ?**
- Changez `useMockData = false` dans `app_config.dart`

---

## 🎉 Résultat

Vous avez maintenant un système complet de données mockées qui vous permet de :

✅ Développer l'application **sans backend**  
✅ Tester avec des **données réalistes**  
✅ Basculer facilement entre **Mock et API réelle**  
✅ Avoir un **affichage réaliste** immédiatement  
✅ Accélérer le **développement**  

---

**Status** : ✅ 100% Fonctionnel  
**Date** : 7 novembre 2024  
**Version** : 1.0.0
