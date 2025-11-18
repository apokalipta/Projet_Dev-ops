# Configuration des permissions pour l'enregistrement audio

## 📱 Android

Ajouter les permissions suivantes dans `android/app/src/main/AndroidManifest.xml` :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions pour l'enregistrement audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    
    <!-- Permission pour accéder au stockage (Android 13+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    
    <!-- Permission pour Internet (envoi des segments) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        ...
    </application>
</manifest>
```

### Fichier complet

Votre `AndroidManifest.xml` devrait ressembler à ceci :

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application
        android:label="meeting_app"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## 🍎 iOS

Ajouter les permissions suivantes dans `ios/Runner/Info.plist` :

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Cette application a besoin d'accéder au microphone pour enregistrer les réunions.</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### Fichier complet

Votre `Info.plist` devrait contenir :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Autres configurations -->
    
    <!-- Permission microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>Cette application a besoin d'accéder au microphone pour enregistrer les réunions.</string>
    
    <!-- Mode arrière-plan pour l'audio -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
    </array>
</dict>
</plist>
```

---

## 🌐 Web

Pour le web, les permissions sont gérées automatiquement par le navigateur via l'API `getUserMedia`.

---

## ✅ Vérification

Après avoir ajouté les permissions :

1. **Nettoyer le build** :
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Rebuild l'application** :
   ```bash
   flutter run
   ```

3. **Tester** :
   - Créer une réunion
   - L'application devrait demander la permission microphone
   - Accepter la permission
   - L'enregistrement devrait démarrer

---

## 🔧 Troubleshooting

### Permission refusée

Si la permission est refusée :
- **Android** : Aller dans Paramètres > Apps > Meeting App > Permissions > Microphone
- **iOS** : Aller dans Réglages > Meeting App > Microphone

### L'enregistrement ne démarre pas

1. Vérifier que les permissions sont bien dans le manifest
2. Désinstaller et réinstaller l'application
3. Vérifier les logs : `flutter logs`

---

## 📝 Notes

- Les permissions sont demandées automatiquement au premier lancement de l'enregistrement
- Le package `permission_handler` gère les demandes de permission
- Le package `record` gère l'enregistrement audio
