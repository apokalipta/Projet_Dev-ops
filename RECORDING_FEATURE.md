# 🎙️ Fonctionnalité d'enregistrement de réunion en direct

## ✅ Ce qui a été implémenté

### 1. **Écran d'enregistrement** (`meeting_recording_screen.dart`)

Interface complète avec :
- ⏱️ **Timer** affichant le temps écoulé depuis le début
- 🎵 **Égaliseur audio animé** (20 barres) qui réagit au niveau sonore
- 🎤 **Sélecteur de source audio** (microphone, téléphone, casque, bluetooth)
- ⏸️ **Bouton Pause/Reprendre** pour mettre en pause l'enregistrement
- ⏹️ **Bouton Terminer** pour arrêter et sauvegarder

### 2. **Provider d'enregistrement** (`recording_provider.dart`)

Gestion complète de l'enregistrement :
- 📹 **Enregistrement automatique** au démarrage
- ⏱️ **Segments de 1 minute** créés automatiquement
- 📤 **Envoi automatique** des segments au serveur toutes les 1 min
- 🔊 **Niveau audio en temps réel** (0-100%)
- ⏸️ **Pause/Reprendre** l'enregistrement
- 🎤 **Changement de source audio**
- 🧹 **Nettoyage automatique** des ressources

### 3. **Flux technique**

```
Création réunion
    ↓
Navigation vers /meeting-recording
    ↓
Démarrage automatique de l'enregistrement
    ↓
Création de segments de 1 min
    ↓
Envoi automatique au serveur
    ↓
Suppression locale après envoi réussi
    ↓
Fin de l'enregistrement
    ↓
Envoi du dernier segment
    ↓
Notification au serveur
```

---

## 🎨 Interface utilisateur

### Écran principal

```
┌─────────────────────────────────┐
│  [←]  Nom de la réunion     │
├─────────────────────────────────┤
│                                 │
│   ENREGISTREMENT EN COURS       │
│   🔴 00:15:42                   │
│                                 │
│   ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐         │
│   │ │ │ │ │ │ │ │ │ │ │         │
│   │ │ │ │ │ │ │ │ │ │ │         │
│   │ │ │ │ │ │ │ │ │ │ │         │
│   └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘         │
│   Niveau: 75%                   │
│                                 │
│   ┌───────────────────────┐     │
│   │ 🎤 Source audio       │     │
│   │ ▼ Microphone par défaut│     │
│   └───────────────────────┘     │
│                                 │
│     ⏸️        ⏹️               │
│    Pause    Terminer            │
│                                 │
└─────────────────────────────────┘
```

---

## 📡 Endpoints API (à implémenter côté backend)

### 1. Envoi de segment audio

```http
POST /api/transcribe/segment
Content-Type: multipart/form-data

{
  "meetingId": "123456789",
  "segment": [fichier audio .m4a],
  "timestamp": "2025-11-18T20:30:00Z"
}
```

**Réponse** :
```json
{
  "success": true,
  "segmentId": "seg_123",
  "message": "Segment reçu et en cours de traitement"
}
```

### 2. Notification de fin d'enregistrement

```http
POST /api/transcribe/complete
Content-Type: application/json

{
  "meetingId": "123456789",
  "segmentCount": 15,
  "completedAt": "2025-11-18T20:45:00Z"
}
```

**Réponse** :
```json
{
  "success": true,
  "message": "Enregistrement terminé, transcription en cours"
}
```

---

## 🔧 Configuration technique

### Packages utilisés

- `record: ^5.0.4` - Enregistrement audio
- `audioplayers: ^5.2.1` - Visualisation audio
- `permission_handler: ^11.0.1` - Gestion des permissions
- `path_provider: ^2.0.11` - Accès au stockage
- `dio: ^5.4.3+1` - Envoi HTTP

### Format audio

- **Codec** : AAC-LC (`.m4a`)
- **Bitrate** : 128 kbps
- **Sample rate** : 44.1 kHz
- **Durée par segment** : 1 minute

### Stockage local

```
/data/user/0/com.example.projetia/app_flutter/recordings/
  └── {meetingId}/
      ├── segment_1700342400000.m4a
      ├── segment_1700342460000.m4a
      └── segment_1700342520000.m4a
```

Les fichiers sont **supprimés automatiquement** après envoi réussi au serveur.

---

## 🎯 Fonctionnalités

### ✅ Implémentées

- [x] Timer temps écoulé
- [x] Égaliseur audio animé
- [x] Sélecteur de source audio (UI)
- [x] Pause/Reprendre
- [x] Arrêt de l'enregistrement
- [x] Segments de 1 minute
- [x] Envoi automatique au serveur
- [x] Niveau audio en temps réel
- [x] Confirmation avant arrêt
- [x] Protection contre retour arrière
- [x] Nettoyage automatique des fichiers

### ⏳ À implémenter (backend)

- [ ] Endpoint `/api/transcribe/segment`
- [ ] Endpoint `/api/transcribe/complete`
- [ ] Traitement des segments audio
- [ ] Transcription en temps réel
- [ ] Stockage des fichiers audio

### 🔮 Améliorations futures

- [ ] Changement réel de source audio (dépend du package)
- [ ] Visualisation spectrogramme
- [ ] Détection automatique de parole
- [ ] Compression audio avant envoi
- [ ] Mode hors ligne avec synchronisation
- [ ] Indicateur de qualité audio
- [ ] Réduction de bruit

---

## 🚀 Utilisation

### 1. Créer une réunion

```dart
// L'utilisateur remplit le formulaire de création
// Clique sur "Créer la Réunion"
```

### 2. Enregistrement automatique

```dart
// L'app navigue vers /meeting-recording/{id}
// L'enregistrement démarre automatiquement
// Les segments sont envoyés toutes les 1 min
```

### 3. Contrôles

```dart
// Pause : met en pause l'enregistrement
// Reprendre : continue l'enregistrement
// Terminer : arrête et envoie le dernier segment
```

---

## 🔐 Permissions

### Android

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO"/>
```

### iOS

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Cette application a besoin d'accéder au microphone pour enregistrer les réunions.</string>
```

---

## 📝 Notes importantes

### Gestion des erreurs

- Si l'envoi échoue, le fichier est **conservé localement**
- L'enregistrement **continue** même en cas d'erreur réseau
- Les fichiers peuvent être **ré-envoyés** plus tard

### Performance

- Les segments de 1 min évitent la **perte de données**
- L'envoi progressif réduit l'**utilisation mémoire**
- Le format AAC offre un bon **compromis qualité/taille**

### Sécurité

- Les permissions sont demandées **au runtime**
- Les fichiers sont stockés dans le **dossier privé** de l'app
- Les segments sont **supprimés** après envoi réussi

---

## 🐛 Troubleshooting

### L'enregistrement ne démarre pas

1. Vérifier les permissions dans les paramètres
2. Redémarrer l'application
3. Vérifier les logs : `flutter logs`

### Les segments ne sont pas envoyés

1. Vérifier la connexion réseau
2. Vérifier l'URL du serveur dans `recording_provider.dart`
3. Vérifier que le backend est accessible

### Niveau audio toujours à 0

1. Vérifier que le microphone fonctionne
2. Tester avec une autre app d'enregistrement
3. Vérifier les permissions

---

## 📚 Documentation

- [Package record](https://pub.dev/packages/record)
- [Package permission_handler](https://pub.dev/packages/permission_handler)
- [Android Audio Recording](https://developer.android.com/guide/topics/media/mediarecorder)

---

**Créé le** : 18 novembre 2024  
**Version** : 1.0.0  
**Statut** : ✅ Prêt pour les tests
