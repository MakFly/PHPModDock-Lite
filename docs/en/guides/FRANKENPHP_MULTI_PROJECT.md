> [!NOTE]
> This is the English version of the documentation. The content is currently a copy of the French version and needs to be translated.

# FrankenPHP Multi-Project Configuration

## Configuration Actuelle

Votre environnement est configuré avec **une seule instance FrankenPHP** qui sert Laravel et Symfony simultanément via des ports différents.

## Architecture

```
┌─────────────────────────────────────────┐
│         Docker Host (localhost)         │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  frankenphp (instance unique)    │  │
│  │  PHP 8.3.27 (ZTS)                │  │
│  │                                  │  │
│  │  Port 80 → laravel-app.localhost │  │
│  │  ├─ Laravel Framework 12.35.1    │  │
│  │  └─ /var/www/laravel-app/public  │  │
│  │                                  │  │
│  │  Port 80 → symfony-api.localhost │  │
│  │  ├─ Symfony 7.2.9                │  │
│  │  └─ /var/www/symfony-api/public  │  │
│  │                                  │  │
│  │  Port 443 → HTTPS (optionnel)    │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## URLs d'Accès

| Projet  | URL (Mode HTTP par défaut)      | Container           |
|---------|---------------------------------|---------------------|
| Laravel | http://laravel-app.localhost    | laradock_frankenphp |
| Symfony | http://symfony-api.localhost    | laradock_frankenphp |

**Configuration requise** : Ajoutez à votre `/etc/hosts` (Linux/Mac) ou `C:\Windows\System32\drivers\etc\hosts` (Windows) :
```
127.0.0.1 laravel-app.localhost
127.0.0.1 symfony-api.localhost
```

**Mode HTTPS** : Vous pouvez activer HTTPS avec certificats automatiques :
```bash
./scripts/frankenphp-https.sh enable
```

Voir `FRANKENPHP_HTTPS_SETUP.md` pour plus de détails.

## Commandes Utiles

### Démarrage

```bash
# Démarrer FrankenPHP (sert les deux projets)
docker-compose up -d frankenphp

# Rebuild et démarrage
docker-compose up -d --build frankenphp
```

### Arrêt

```bash
# Arrêter tous les containers
docker-compose down

# Arrêter uniquement FrankenPHP
docker-compose stop frankenphp

# Redémarrer FrankenPHP
docker-compose restart frankenphp
```

### Logs

```bash
# Logs FrankenPHP (inclut Laravel et Symfony)
docker logs -f laradock_frankenphp

# Interface graphique (Dozzle)
# http://localhost:8888
```

### Exécution de Commandes

```bash
# Laravel Artisan
docker exec -w /var/www/laravel-app laradock_frankenphp php artisan [command]

# Symfony Console
docker exec -w /var/www/symfony-api laradock_frankenphp php bin/console [command]

# Composer (Laravel)
docker exec -w /var/www/laravel-app laradock_frankenphp composer [command]

# Composer (Symfony)
docker exec -w /var/www/symfony-api laradock_frankenphp composer [command]
```

## Configuration Technique

### Fichiers Modifiés

1. **docker-compose.yml**
   - Un seul service `frankenphp` avec mapping de ports multiples
   - Ports mappés : `8080:8080`, `8081:8081`, `8443:443`
   - Configuration simplifiée sans variables SERVER_NAME/SERVER_ROOT

2. **.env**
   ```bash
   FRANKENPHP_HTTP_PORT_LARAVEL=8080
   FRANKENPHP_HTTP_PORT_SYMFONY=8081
   FRANKENPHP_HTTPS_PORT=8443
   ```

3. **services/frankenphp/config/Caddyfile**
   - Deux blocs serveur distincts dans le même fichier
   - Chaque bloc écoute sur son propre port (:8080, :8081)
   - Chemins hardcodés directement dans le Caddyfile
   - Logging activé pour le debugging

### Configuration Caddyfile

Le Caddyfile utilise des hostnames pour activer HTTPS automatiquement :

```caddyfile
{
    # HTTPS automatiquement activé pour les hostnames
    # Caddy génère des certificats locaux et les installe dans votre trust store
}

# Laravel Application - HTTPS automatique
laravel-app.localhost {
    root * /var/www/laravel-app/public
    encode zstd br gzip
    log { output stdout; format console; level INFO }
    php_server
}

# Symfony Application - HTTPS automatique
symfony-api.localhost {
    root * /var/www/symfony-api/public
    encode zstd br gzip
    log { output stdout; format console; level INFO }
    php_server
}
```

**Magie de FrankenPHP** : En utilisant des hostnames au lieu de ports (`:8080`), Caddy active automatiquement HTTPS !

## Avantages de Cette Architecture

✅ **Efficacité des Ressources**
- Un seul processus PHP pour les deux projets
- Moins de mémoire consommée qu'avec 2 instances
- Opcache partagé entre les projets

✅ **Simplicité de Gestion**
- Un seul container à démarrer/arrêter
- Configuration centralisée dans le Caddyfile
- Monitoring simplifié

✅ **Scalabilité**
- Facile d'ajouter un 3ème projet (nouveau bloc dans Caddyfile)
- Pattern officiel FrankenPHP pour multi-projets
- Gestion des ports intuitive

✅ **Maintenance**
- Un seul Caddyfile à maintenir
- Logs centralisés avec distinction par port
- Moins de duplication de configuration

## Ajouter un Nouveau Projet

### Étape 1 : Ajouter un Bloc Serveur dans le Caddyfile

Dans `services/frankenphp/config/Caddyfile`, ajouter :

```caddyfile
# MyApp Application - Port 8082
:8082 {
    root * /var/www/myapp/public
    encode zstd br gzip
    log {
        output stdout
        format console
        level {$LOG_LEVEL:INFO}
    }
    php_server
}
```

### Étape 2 : Ajouter le Port Mapping

Dans `docker-compose.yml`, section `frankenphp` :

```yaml
ports:
  - "${FRANKENPHP_HTTP_PORT_LARAVEL}:8080"
  - "${FRANKENPHP_HTTP_PORT_SYMFONY}:8081"
  - "${FRANKENPHP_HTTP_PORT_MYAPP}:8082"     # Nouvelle ligne
  - "${FRANKENPHP_HTTPS_PORT}:443"
  - "${FRANKENPHP_HTTPS_PORT}:443/udp"
```

### Étape 3 : Ajouter la Variable de Port dans .env

```bash
# FrankenPHP Ports (Single Instance, Multi-Project)
FRANKENPHP_HTTP_PORT_LARAVEL=8080
FRANKENPHP_HTTP_PORT_SYMFONY=8081
FRANKENPHP_HTTP_PORT_MYAPP=8082            # Nouvelle ligne
FRANKENPHP_HTTPS_PORT=8443
```

### Étape 4 : Créer le Projet

```bash
# Créer le dossier
mkdir -p projects/myapp

# Initialiser le projet (Laravel ou Symfony)
# Pour Laravel:
docker-compose run --rm workspace composer create-project laravel/laravel myapp

# Pour Symfony:
docker-compose run --rm workspace composer create-project symfony/skeleton myapp
```

### Étape 5 : Rebuilder et Redémarrer

```bash
docker-compose up -d --build frankenphp
```

Votre nouveau projet sera accessible sur http://localhost:8082

## Monitoring et Debugging

### Health Checks

FrankenPHP inclut des health checks automatiques. Vérifiez l'état :

```bash
docker ps --filter "name=frankenphp"
```

Cherchez la colonne `STATUS` - elle devrait afficher `healthy`.

### Performance

Chaque instance FrankenPHP utilise :
- **Workers**: 2 (configurable via `FRANKENPHP_NUM_WORKERS`)
- **Threads**: 4 (configurable via `FRANKENPHP_NUM_THREADS`)

Pour un environnement de production, augmentez ces valeurs dans `.env`.

### Dozzle (Interface Web des Logs)

Accédez à http://localhost:8888 pour voir tous les logs Docker en temps réel avec une interface graphique.

## Résolution de Problèmes

### Un projet ne répond pas

```bash
# Vérifier les logs
docker logs laradock_frankenphp_laravel

# Redémarrer le container
docker-compose restart frankenphp-laravel

# Reconstruire si nécessaire
docker-compose build frankenphp-laravel
docker-compose up -d frankenphp-laravel
```

### Port déjà utilisé

Si un port est occupé, changez-le dans `.env` :

```bash
FRANKENPHP_LARAVEL_HTTP_PORT=8090  # Au lieu de 8080
```

Puis redémarrez :

```bash
docker-compose up -d frankenphp-laravel
```

### Permissions fichiers

Si vous avez des erreurs de permissions :

```bash
# Vérifier PUID/PGID dans .env
echo "PUID: $(id -u)"
echo "PGID: $(id -g)"

# Rebuild avec les bons IDs
docker-compose build frankenphp-laravel frankenphp-symfony
docker-compose up -d frankenphp-laravel frankenphp-symfony
```

## Ressources

- [FrankenPHP Documentation](https://frankenphp.dev/fr/docs/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Laravel Octane + FrankenPHP](https://laravel.com/docs/octane#frankenphp)
- [Symfony + FrankenPHP](https://symfony.com/doc/current/deployment/frankenphp.html)

## Support

Pour plus d'informations, consultez :
- `services/frankenphp/README.md` - Configuration détaillée FrankenPHP
- `README.md` - Documentation générale Laradock Lite
