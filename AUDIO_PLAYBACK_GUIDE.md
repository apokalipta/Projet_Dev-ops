# 🎵 Guide du système de lecture audio

## 📋 Vue d'ensemble

Le système de lecture audio permet de **réécouter les réunions terminées** avec une **synchronisation automatique** entre l'audio et la transcription.

---

## ✅ Ce qui a été créé

### Fichiers créés (5 fichiers)

1. **`lib/src/core/data/mock_audio_data.dart`** - URLs audio mockées pour les tests
2. **`lib/src/features/meeting/presentation/providers/audio_player_provider.dart`** - Provider Riverpod pour le player audio
3. **`lib/src/features/meeting/presentation/screens/meeting_details_screen.dart`** - Écran de détails avec bouton "Réécouter"
4. **`lib/src/features/meeting/presentation/screens/meeting_playback_screen.dart`** - Écran de lecture avec player synchronisé
5. **`pubspec.yaml`** - Ajout des packages `just_audio` et `audio_video_progress_bar`

### Routes ajoutées

- `/meeting-details/:id` - Détails d'une réunion
- `/meeting-playback/:id` - Lecture d'une réunion avec audio

---

## 🎯 Fonctionnalités

### Player audio

✅ **Play/Pause** - Lecture et pause de l'audio  
✅ **Barre de progression** - Affichage et navigation dans l'audio  
✅ **Avancer/Reculer 10s** - Contrôles rapides  
✅ **Vitesse de lecture** - 0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x  
✅ **Position actuelle** - Affichage du temps écoulé et total  

### Synchronisation

✅ **Surlignage automatique** - Le segment en cours de lecture est surligné  
✅ **Scroll automatique** - L'écran scroll automatiquement vers le segment actuel  
✅ **Navigation par segment** - Cliquer sur un segment pour y aller directement  
✅ **Indicateur visuel** - Badge "En cours de lecture" sur le segment actuel  

---

## 🚀 Utilisation

### 1. Accéder à une réunion terminée

```dart
// Depuis la liste des réunions
context.push('/meeting-details/meeting-001');
```

### 2. Voir les détails

L'écran de détails affiche :
- Statut de la réunion (Terminée/Planifiée)
- Informations (date, durée, lieu, langue)
- Statistiques (temps de parole, silence)
- Liste des participants avec leurs stats
- **Bouton "Réécouter la réunion"** (si audio disponible)

### 3. Lancer la lecture

Cliquer sur le bouton **"Réécouter la réunion"** pour accéder au player.

### 4. Contrôler la lecture

- **Play/Pause** : Bouton central
- **Avancer/Reculer** : Boutons ⏪ et ⏩ (10 secondes)
- **Chercher** : Glisser la barre de progression
- **Vitesse** : Menu en haut à droite (icône ⚡)
- **Aller à un segment** : Cliquer sur un segment dans la liste

---

## 📊 Données disponibles

### Réunions avec audio (4 réunions)

| ID | Titre | Durée | Segments |
|----|-------|-------|----------|
| meeting-001 | Sprint Planning | 1h | 5 segments |
| meeting-002 | Revue de code Backend | 1h30 | 3 segments |
| meeting-003 | Présentation Client | 45min | 0 segments |
| meeting-005 | Rétrospective Sprint | 1h15 | 0 segments |

**Note** : Les URLs audio sont des fichiers MP3 de test publics. En production, elles seront remplacées par les vrais enregistrements.

---

## 🎨 Interface utilisateur

### Écran de détails

```
┌─────────────────────────────────────┐
│ ← Réunion équipe Dev                │
├─────────────────────────────────────┤
│ ✅ Terminée                          │
│                                     │
│ 📋 Informations                     │
│ 📅 Date: 7 Nov 2024 à 14:00        │
│ ⏱️  Durée: 60 minutes               │
│ 📍 Lieu: Salle de réunion A         │
│                                     │
│ 📊 Statistiques                     │
│ ⏱️  Durée totale: 60 min            │
│ 🎤 Temps de parole: 57 min          │
│ 🔇 Temps de silence: 3 min          │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ ▶️ Réécouter la réunion         │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 👥 Participants                     │
│ • Alice Dupont (20 min - 35%)      │
│ • Bob Martin (15 min - 26%)        │
│ • Claire Leroy (17.5 min - 31%)    │
│ • David Chen (7.5 min - 13%)       │
└─────────────────────────────────────┘
```

### Écran de lecture

```
┌─────────────────────────────────────┐
│ ← Réunion équipe Dev           ⚡   │
├─────────────────────────────────────┤
│ ▬▬▬▬▬▬▬▬▬●▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ │
│ 12:30                        60:00 │
│                                     │
│      ⏪        ▶️        ⏩          │
│           (Play/Pause)              │
│                                     │
│         Vitesse: 1.0x               │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 👤 Alice Dupont     00:00       │ │
│ │ Tech Lead                       │ │
│ │                                 │ │
│ │ Bonjour à tous, commençons...   │ │
│ │ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ 95%       │ │
│ │ ▶️ En cours de lecture          │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 David Chen       00:12       │ │
│ │ Product Owner                   │ │
│ │                                 │ │
│ │ Parfait Alice. J'ai préparé...  │ │
│ │ ▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬ 92%        │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🔧 Configuration

### Ajouter de nouveaux audios

Éditez `lib/src/core/data/mock_audio_data.dart` :

```dart
static const Map<String, String> audioUrls = {
  'meeting-001': 'https://votre-url-audio.com/meeting-001.mp3',
  'meeting-002': 'https://votre-url-audio.com/meeting-002.mp3',
  // Ajoutez vos URLs ici
};
```

### Changer la vitesse par défaut

Dans `meeting_playback_screen.dart` :

```dart
double _playbackSpeed = 1.0; // Changez cette valeur
```

### Personnaliser les couleurs

Le segment actuel utilise la couleur primaire du thème :

```dart
color: isCurrentSegment
    ? Theme.of(context).primaryColor.withOpacity(0.1)
    : null,
```

---

## 📱 Utilisation dans le code

### Initialiser le player

```dart
// Le player s'initialise automatiquement au chargement de l'écran
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref
        .read(audioPlayerNotifierProvider.notifier)
        .initializePlayer(widget.meetingId);
  });
}
```

### Contrôler le player

```dart
final playerNotifier = ref.read(audioPlayerNotifierProvider.notifier);

// Play/Pause
await playerNotifier.togglePlayPause();

// Aller à une position
await playerNotifier.seek(Duration(seconds: 30));

// Aller à un segment
await playerNotifier.seekToSegment(meetingId, segmentId);

// Changer la vitesse
await playerNotifier.setSpeed(1.5);

// Avancer/Reculer
await playerNotifier.forward10();
await playerNotifier.backward10();
```

### Écouter l'état du player

```dart
final playerState = ref.watch(audioPlayerNotifierProvider);

// État
bool isPlaying = playerState.isPlaying;
bool isLoading = playerState.isLoading;

// Position
Duration currentPosition = playerState.currentPosition;
Duration totalDuration = playerState.totalDuration;
double progress = playerState.progress; // 0.0 à 1.0

// Segment actuel
String? currentSegmentId = playerState.currentSegmentId;

// Erreur
String? error = playerState.error;
```

---

## 🎯 Cas d'usage

### Cas 1 : Utilisateur veut réécouter une réunion

1. Ouvre la liste des réunions
2. Clique sur une réunion terminée
3. Voit les détails et statistiques
4. Clique sur "Réécouter la réunion"
5. L'audio démarre, la transcription s'affiche
6. Peut naviguer dans l'audio et la transcription

### Cas 2 : Utilisateur veut retrouver un passage précis

1. Ouvre le player de la réunion
2. Scroll dans la liste des segments
3. Clique sur le segment recherché
4. L'audio saute à ce segment
5. Peut lire à vitesse accélérée (1.5x ou 2x)

### Cas 3 : Utilisateur veut vérifier la transcription

1. Écoute l'audio
2. Suit la transcription en temps réel
3. Voit le score de confiance de chaque segment
4. Peut identifier les segments à corriger (score < 90%)

---

## ⚠️ Important

### Limitations actuelles

- ❌ **Pas d'édition** de la transcription pendant la lecture
- ❌ **Pas de marque-pages** pour sauvegarder des positions
- ❌ **Pas de téléchargement** offline de l'audio
- ❌ **Pas de partage** de timestamp

### Prochaines fonctionnalités

- [ ] Édition de la transcription en temps réel
- [ ] Marque-pages et favoris
- [ ] Téléchargement pour écoute offline
- [ ] Partage de timestamp (ex: "Écouter à partir de 12:30")
- [ ] Recherche dans la transcription
- [ ] Export de la transcription (PDF, TXT)

---

## 🐛 Résolution de problèmes

### L'audio ne se charge pas

**Problème** : Le player affiche "Chargement..." indéfiniment

**Solutions** :
1. Vérifier que l'URL audio est accessible
2. Vérifier la connexion internet
3. Vérifier les logs d'erreur dans `playerState.error`

### La synchronisation ne fonctionne pas

**Problème** : Le segment ne se surligne pas pendant la lecture

**Solutions** :
1. Vérifier que les timestamps des segments sont corrects
2. Vérifier que `currentSegmentId` est mis à jour
3. Vérifier les logs du provider

### Le scroll automatique ne fonctionne pas

**Problème** : L'écran ne scroll pas vers le segment actuel

**Solutions** :
1. Vérifier que les `GlobalKey` sont bien créées
2. Vérifier que `_scrollToSegment()` est appelée
3. Augmenter le délai dans `addPostFrameCallback`

---

## 📚 Packages utilisés

### just_audio (^0.9.36)

Player audio cross-platform avec support :
- Streaming audio depuis URL
- Contrôle de la vitesse de lecture
- Gestion de la position et de la durée
- États de lecture (playing, paused, stopped)

**Documentation** : https://pub.dev/packages/just_audio

### audio_video_progress_bar (^2.0.1)

Barre de progression personnalisable avec :
- Affichage du temps écoulé et total
- Drag pour chercher dans l'audio
- Personnalisation des couleurs
- Support du buffering

**Documentation** : https://pub.dev/packages/audio_video_progress_bar

---

## 🎓 Exemples avancés

### Exemple 1 : Ajouter des marque-pages

```dart
class BookmarkButton extends ConsumerWidget {
  final String meetingId;
  final Duration position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.bookmark_add),
      onPressed: () {
        // Sauvegarder le marque-page
        final bookmark = {
          'meetingId': meetingId,
          'position': position.inSeconds,
          'timestamp': DateTime.now(),
        };
        // Sauvegarder dans la base de données
      },
    );
  }
}
```

### Exemple 2 : Partager un timestamp

```dart
void shareTimestamp(String meetingId, Duration position) {
  final minutes = position.inMinutes;
  final seconds = position.inSeconds % 60;
  final timestamp = '$minutes:${seconds.toString().padLeft(2, '0')}';
  
  final shareText = 'Écouter à partir de $timestamp\n'
      'meeting-playback/$meetingId?t=${position.inSeconds}';
  
  // Utiliser share_plus pour partager
  Share.share(shareText);
}
```

### Exemple 3 : Recherche dans la transcription

```dart
class TranscriptionSearch extends StatefulWidget {
  final String meetingId;

  @override
  State<TranscriptionSearch> createState() => _TranscriptionSearchState();
}

class _TranscriptionSearchState extends State<TranscriptionSearch> {
  String _searchQuery = '';
  
  List<Map<String, dynamic>> _searchResults(List<Map<String, dynamic>> segments) {
    if (_searchQuery.isEmpty) return segments;
    
    return segments.where((segment) {
      final text = segment['text'] as String;
      return text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    final segments = MockData.getSegments(widget.meetingId);
    final results = _searchResults(segments);
    
    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Rechercher dans la transcription...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final segment = results[index];
              return _buildSegmentCard(segment);
            },
          ),
        ),
      ],
    );
  }
}
```

---

## ✅ Checklist

- [x] Packages audio installés
- [x] Provider audio créé
- [x] Écran de détails créé
- [x] Écran de lecture créé
- [x] Routes configurées
- [x] Navigation depuis la liste
- [x] Synchronisation audio/texte
- [x] Contrôles de lecture
- [x] Vitesse de lecture
- [x] Scroll automatique
- [ ] Tests avec de vrais fichiers audio
- [ ] Gestion offline
- [ ] Marque-pages
- [ ] Partage de timestamp

---

**Status** : ✅ Fonctionnel avec données mockées  
**Date** : 7 novembre 2024  
**Version** : 1.0.0

**Prochaine étape** : Tester avec de vrais fichiers audio et implémenter les fonctionnalités avancées !
