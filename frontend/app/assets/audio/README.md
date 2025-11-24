# Audio Assets

## Fichier audio de démonstration

Pour que la réunion de démonstration fonctionne avec l'audio, vous devez placer un fichier audio MP3 dans ce dossier.

### Fichier requis :
- **Nom** : `demo_meeting.mp3`
- **Format** : MP3
- **Durée recommandée** : ~95 secondes (pour correspondre aux segments de transcription)

### Comment obtenir un fichier audio de test :

1. **Option 1 - Enregistrer votre propre audio** :
   - Enregistrez une conversation de ~95 secondes
   - Convertissez-la en MP3
   - Renommez-la en `demo_meeting.mp3`

2. **Option 2 - Utiliser un générateur de voix** :
   - Utilisez un service TTS (Text-to-Speech) comme :
     - Google Cloud Text-to-Speech
     - Amazon Polly
     - ElevenLabs
   - Générez l'audio à partir des textes de transcription
   - Exportez en MP3

3. **Option 3 - Fichier audio silencieux (pour test)** :
   - Créez un fichier MP3 silencieux de 95 secondes
   - Cela permettra de tester l'interface sans audio réel

### Structure attendue :
```
assets/
  audio/
    demo_meeting.mp3  ← Placez votre fichier ici
    README.md         ← Ce fichier
```

### Note :
Le lecteur audio est déjà configuré pour charger `assets/audio/demo_meeting.mp3` pour la réunion de démonstration (ID: demo-999).
