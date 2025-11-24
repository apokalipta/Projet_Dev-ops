const CACHE_PREFIX = 'api-cache-';
const DEFAULT_TTL = 3600000; // 1 heure en millisecondes

class CacheService {
  constructor() {
    this.cache = new Map();
    this.initialized = false;
  }

  initialize() {
    if (this.initialized || typeof window === 'undefined') return;
    
    try {
      // Charger le cache depuis localStorage
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key.startsWith(CACHE_PREFIX)) {
          try {
            const item = JSON.parse(localStorage.getItem(key));
            // Vérifier si l'élément a expiré
            if (item?.expiresAt > Date.now()) {
              this.cache.set(key.replace(CACHE_PREFIX, ''), item);
            } else {
              localStorage.removeItem(key);
            }
          } catch (e) {
            console.warn(`Échec du chargement de l'entrée de cache ${key}:`, e);
            localStorage.removeItem(key);
          }
        }
      }
      
      this.initialized = true;
      console.log('Cache initialisé avec succès');
    } catch (error) {
      console.error('Erreur lors de l\'initialisation du cache:', error);
      this.initialized = false;
    }
  }

  get(key) {
    if (typeof window === 'undefined') return null;
    if (!this.initialized) this.initialize();
    
    const cacheKey = CACHE_PREFIX + key;
    const item = this.cache.get(key);
    
    if (!item) {
      // Essayer de récupérer depuis localStorage si pas dans le cache mémoire
      try {
        const storedItem = localStorage.getItem(cacheKey);
        if (storedItem) {
          const parsedItem = JSON.parse(storedItem);
          if (parsedItem?.expiresAt > Date.now()) {
            this.cache.set(key, parsedItem);
            return parsedItem.data;
          } else {
            this._removeFromStorage(cacheKey);
          }
        }
      } catch (e) {
        console.warn('Erreur lors de la lecture du cache depuis localStorage:', e);
      }
      return null;
    }

    // Vérifier si le cache a expiré
    if (item.expiresAt < Date.now()) {
      this._removeFromStorage(cacheKey);
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }

  set(key, data, ttl = DEFAULT_TTL) {
    if (typeof window === 'undefined') return;
    if (!this.initialized) this.initialize();
    
    const cacheKey = CACHE_PREFIX + key;
    const item = {
      data,
      expiresAt: Date.now() + ttl,
      cachedAt: new Date().toISOString()
    };
    
    this.cache.set(key, item);
    
    try {
      localStorage.setItem(cacheKey, JSON.stringify(item));
    } catch (e) {
      console.error('Erreur lors de la sauvegarde dans le cache:', e);
      // Si le localStorage est plein, on essaie de faire de la place
      if (e.name === 'QuotaExceededError') {
        this._clearExpired();
        try {
          localStorage.setItem(cacheKey, JSON.stringify(item));
        } catch (e2) {
          console.error('Impossible de sauvegarder dans le cache après nettoyage:', e2);
        }
      }
    }
  }

  delete(key) {
    if (typeof window === 'undefined') return false;
    if (!this.initialized) this.initialize();
    
    const cacheKey = CACHE_PREFIX + key;
    this._removeFromStorage(cacheKey);
    return this.cache.delete(key);
  }

  clear() {
    if (typeof window === 'undefined') return;
    
    try {
      // Supprimer uniquement les clés de notre cache
      const keysToRemove = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key.startsWith(CACHE_PREFIX)) {
          keysToRemove.push(key);
        }
      }
      
      keysToRemove.forEach(key => localStorage.removeItem(key));
      this.cache.clear();
      console.log('Cache vidé avec succès');
      return true;
    } catch (error) {
      console.error('Erreur lors de la suppression du cache:', error);
      return false;
    }
  }

  _removeFromStorage(key) {
    try {
      localStorage.removeItem(key);
    } catch (e) {
      console.warn('Échec de la suppression du cache:', e);
    }
  }

  _clearExpired() {
    if (typeof window === 'undefined') return;
    
    const now = Date.now();
    const keysToRemove = [];
    
    // Identifier les clés expirées
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key.startsWith(CACHE_PREFIX)) {
        try {
          const item = JSON.parse(localStorage.getItem(key));
          if (item?.expiresAt < now) {
            keysToRemove.push(key);
          }
        } catch (e) {
          keysToRemove.push(key);
        }
      }
    }
    
    // Supprimer les entrées expirées
    keysToRemove.forEach(key => {
      this._removeFromStorage(key);
      this.cache.delete(key.replace(CACHE_PREFIX, ''));
    });
    
    if (keysToRemove.length > 0) {
      console.log(`Nettoyage du cache: ${keysToRemove.length} entrées expirées supprimées`);
    }
  }
}

export const cacheService = new CacheService();

// Initialiser le cache au chargement du module
if (typeof window !== 'undefined') {
  // Initialiser le cache après un court délai pour ne pas bloquer le chargement de la page
  setTimeout(() => cacheService.initialize(), 100);
}
