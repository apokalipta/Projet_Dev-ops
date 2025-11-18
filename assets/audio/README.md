# Dossier Audio

## 📁 Placement du fichier audio

Placez votre fichier **`audio.mp3`** dans ce dossier :

```
assets/
  └── audio/
      └── audio.mp3  ← Votre fichier audio ici
```

## 🎵 Format supporté

- **Format** : MP3
- **Nom** : `audio.mp3`
- **Utilisation** : Lecture audio dans l'écran de transcription

## 🔧 Configuration

Le fichier est déjà configuré dans `pubspec.yaml` :

```yaml
flutter:
  assets:
    - assets/audio/
```

## 📝 Note

Si vous n'avez pas encore de fichier audio, l'application fonctionnera quand même mais le lecteur audio affichera une erreur de chargement.
