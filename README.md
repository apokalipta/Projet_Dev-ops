# Projet de Transcription IA

## Fonctionnalité de Cache d'API

### Présentation

Le système intègre une fonctionnalité de cache pour les appels API qui permet de :
- Améliorer les performances en évitant des appels réseau inutiles
- Fournir une expérience utilisateur plus fluide en cas de problèmes de connexion
- Réduire la charge sur le serveur en réutilisant les données mises en cache

### Comment ça fonctionne

1. **Mise en cache automatique** :
   - Toutes les réponses des requêtes GET sont automatiquement mises en cache pendant 1 heure
   - Le cache est stocké dans un fichier JSON situé dans le dossier `.api-cache/`
   - Les données sont automatiquement invalidées après leur durée de vie (TTL)

2. **Récupération depuis le cache** :
   - Si l'API est indisponible, le système utilise automatiquement les données en cache
   - Un message d'avertissement est affiché dans la console lorsque des données en cache sont utilisées

### Gestion du cache

#### Vider le cache manuellement

Pour vider manuellement le cache, vous pouvez :

1. Supprimer le dossier `.api-cache/` à la racine du projet
2. Redémarrer l'application pour que les changements prennent effet

#### Désactiver le cache (développement uniquement)

Pour désactiver temporairement le cache pendant le développement, modifiez le fichier `src/services/api.js` et remplacez :

```javascript
// Mettre en cache les réponses GET réussies
if ((!options.method || options.method.toUpperCase() === 'GET') && isJson) {
  try {
    // Mettre en cache pendant 1 heure par défaut
    await cacheService.set(cacheKey, body, 3600000);
  } catch (cacheError) {
    console.warn('Erreur lors de la mise en cache:', cacheError);
  }
}
```

Par :

```javascript
// Cache désactivé pour le développement
console.log('Cache désactivé pour le développement');
```

### Bonnes pratiques

- **En production** : Laissez le cache activé pour de meilleures performances
- **Pendant le développement** : Si vous rencontrez des problèmes avec des données obsolètes, videz le cache
- **Après les mises à jour** : Videz toujours le cache après une mise à jour majeure de l'API

### Fichiers de cache

- Emplacement : `.api-cache/api-cache.json`
- Format : JSON contenant les données mises en cache avec leurs métadonnées
- Taille : La taille du cache est limitée par l'espace disque disponible

### Dépannage

Si vous rencontrez des problèmes avec le cache :

1. Vérifiez les journaux de la console pour les erreurs liées au cache
2. Essayez de vider le cache manuellement
3. Vérifiez les permissions du dossier `.api-cache/`
4. Assurez-vous que l'application a les droits en écriture sur le dossier du projet