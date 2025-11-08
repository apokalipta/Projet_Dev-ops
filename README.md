# Projet IA - Application de Gestion de Réunions

Application Flutter pour la gestion de réunions avec transcription automatique et analyse par IA.

## 📚 Documentation

- **[DEVELOPPEMENT_LOCAL.md](DEVELOPPEMENT_LOCAL.md)** - Guide de développement local
- **[API_SPECIFICATION.md](API_SPECIFICATION.md)** - Spécification complète des endpoints API
- **[INTEGRATION_API.md](INTEGRATION_API.md)** - Guide d'intégration des services API
- **[lib/src/core/api/README.md](lib/src/core/api/README.md)** - Documentation technique des services API

## 🚀 Démarrage rapide

### Prérequis

- Flutter SDK (>=3.5.4)
- Dart SDK (>=3.5.4)
- Android Studio / VS Code
- Un émulateur Android ou un appareil physique

### Installation

1. Cloner le projet
2. Installer les dépendances :
   ```bash
   flutter pub get
   ```
3. Générer les fichiers de code :
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Lancer l'application :
   ```bash
   flutter run
   ```

## 🏗️ Architecture

Le projet suit une architecture en couches avec Riverpod pour la gestion d'état :

```
lib/
├── src/
│   ├── core/              # Fonctionnalités communes
│   │   ├── api/          # Services API et configuration
│   │   ├── navigation/   # Système de navigation
│   │   └── theme/        # Thème de l'application
│   └── features/         # Fonctionnalités métier
│       ├── meeting/      # Gestion des réunions
│       └── transcription/ # Gestion des transcriptions
```

## 🔌 Services API

Les services API sont prêts à être utilisés mais **ne sont pas encore connectés au backend**.

### Configuration

Modifiez l'URL du backend dans `lib/src/core/api/api_config.dart` :

```dart
static const String devUrl = 'http://votre-backend-url:8080/api';
```

### Utilisation

```dart
// Dans un widget
final meetingService = ref.watch(meetingApiServiceProvider);
final meetings = await meetingService.getAllMeetings();
```

Consultez [INTEGRATION_API.md](INTEGRATION_API.md) pour des exemples complets.

## 📦 Packages principaux

- **flutter_riverpod** - Gestion d'état
- **go_router** - Navigation
- **dio** - Client HTTP
- **drift** - Base de données locale
- **freezed** - Classes immuables
- **json_serializable** - Sérialisation JSON

## 🧪 Tests

```bash
# Tests unitaires
flutter test

# Tests d'intégration
flutter test integration_test
```

## 📱 Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## 🤝 Contribution

1. Créer une branche feature
2. Commiter les changements
3. Pousser vers la branche
4. Créer une Pull Request

## 📄 Licence

Ce projet est sous licence [à définir].
