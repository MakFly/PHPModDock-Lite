> [!NOTE]
> This is the English version of the documentation. The content is currently a copy of the French version and needs to be translated.

# FrankenPHP HTTPS - Switch HTTP/HTTPS

## 🔐 HTTPS Natif avec FrankenPHP

FrankenPHP utilise Caddy pour activer **HTTPS automatiquement** sans configuration complexe.

## 🚀 Configuration Par Défaut : HTTP

Par défaut, votre environnement est configuré en **mode HTTP uniquement** pour simplifier le développement.

Vous pouvez basculer vers le mode HTTPS à tout moment avec une simple commande.

## ⚡ Switch HTTP/HTTPS

### Voir le Mode Actuel

```bash
./scripts/frankenphp-https.sh status
```

### Activer HTTPS

```bash
./scripts/frankenphp-https.sh enable
```

Cela va :
- ✅ Remplacer le Caddyfile par la version HTTPS
- ✅ Générer automatiquement les certificats locaux
- ✅ Redémarrer FrankenPHP
- ✅ Vos apps seront accessibles en HTTPS

**URLs après activation** :
- https://laravel-app.localhost
- https://symfony-api.localhost

### Désactiver HTTPS (Revenir en HTTP)

```bash
./scripts/frankenphp-https.sh disable
```

Cela va :
- ✅ Restaurer le Caddyfile HTTP
- ✅ Nettoyer le cache Caddy
- ✅ Redémarrer FrankenPHP
- ✅ HTTP accessible sans redirection HTTPS

**URLs après désactivation** :
- http://laravel-app.localhost
- http://symfony-api.localhost

## ✨ Comment ça Marche ?

### Règle Simple de Caddy

- **Hostname dans Caddyfile** → HTTPS automatique
- **Préfixe `http://`** → HTTP uniquement (pas de redirect)
- **`auto_https off`** → Désactive complètement HTTPS

### Deux Configurations

Le système utilise deux Caddyfiles différents :

**1. Mode HTTP** (`services/frankenphp/config/Caddyfile` - par défaut)
```caddyfile
{
    auto_https off  # Désactive HTTPS
}

http://laravel-app.localhost {
    root * /var/www/laravel-app/public
    php_server
}
```

**2. Mode HTTPS** (`services/frankenphp/config/Caddyfile.https`)
```caddyfile
{
    # auto_https activé par défaut
}

laravel-app.localhost {  # Sans préfixe = HTTPS auto
    root * /var/www/laravel-app/public
    php_server
}
```

Le script `frankenphp-https.sh` swap simplement entre ces deux fichiers.

## 📋 Configuration Docker

### Docker Compose

```yaml
frankenphp:
  ports:
    - "80:80"       # HTTP / HTTPS selon le mode
    - "443:443"     # HTTPS (en mode HTTPS uniquement)
    - "443:443/udp" # HTTP/3 (QUIC) (en mode HTTPS uniquement)
```

### Variables d'Environnement (.env)

```bash
# Ports FrankenPHP
FRANKENPHP_HTTP_PORT=80
FRANKENPHP_HTTPS_PORT=443
```

### Fichier /etc/hosts

Ajoutez ces lignes à votre fichier hosts :

**Linux/Mac** : `/etc/hosts`
```
127.0.0.1 laravel-app.localhost
127.0.0.1 symfony-api.localhost
```

**Windows** : `C:\Windows\System32\drivers\etc\hosts`
```
127.0.0.1 laravel-app.localhost
127.0.0.1 symfony-api.localhost
```

## 🔑 Certificats Automatiques

### Premier Démarrage

Au premier démarrage, Caddy va :

1. **Créer sa propre CA (Certificate Authority)**
   - Stockée dans le container FrankenPHP
   - Valide uniquement pour votre machine

2. **Générer des certificats pour chaque hostname**
   - `laravel-app.localhost`
   - `symfony-api.localhost`

3. **Tenter d'installer la CA dans votre trust store**
   - **Linux** : Peut demander votre mot de passe sudo
   - **Mac** : Peut demander confirmation Keychain
   - **Windows** : Peut demander droits administrateur

### Accepter les Certificats

Si Caddy ne peut pas installer automatiquement :

**Option 1 : Accepter manuellement dans le navigateur**
- Cliquez sur "Avancé" → "Accepter le risque"
- À faire une seule fois par domaine

**Option 2 : Installer manuellement la CA**
```bash
# Depuis le container
docker exec -it laradock_frankenphp caddy trust
```

## 🌐 URLs d'Accès

### Mode HTTP (par défaut)

| Projet  | URL                           |
|---------|-------------------------------|
| Laravel | http://laravel-app.localhost  |
| Symfony | http://symfony-api.localhost  |

### Mode HTTPS (après `./scripts/frankenphp-https.sh enable`)

| Projet  | URL HTTPS                      | URL HTTP                      |
|---------|--------------------------------|-------------------------------|
| Laravel | https://laravel-app.localhost  | http://laravel-app.localhost (redirige vers HTTPS) |
| Symfony | https://symfony-api.localhost  | http://symfony-api.localhost (redirige vers HTTPS) |

## 📋 Vérifications

### Tester le Mode HTTP

```bash
# Vérifier le statut
./scripts/frankenphp-https.sh status

# Tester Laravel
curl http://laravel-app.localhost

# Tester Symfony
curl http://symfony-api.localhost
```

### Tester le Mode HTTPS

```bash
# Activer HTTPS
./scripts/frankenphp-https.sh enable

# Vérifier le statut
./scripts/frankenphp-https.sh status

# Tester avec curl (ignore la vérification du certificat auto-signé)
curl -k https://laravel-app.localhost
curl -k https://symfony-api.localhost
```

L'option `-k` ignore la vérification du certificat (utile pour les certificats auto-signés).

### Voir les Certificats (en mode HTTPS)

```bash
# Vérifier les certificats générés
docker exec laradock_frankenphp ls -la /data/caddy/certificates/

# Voir les logs de génération de certificats
docker logs laradock_frankenphp | grep -i cert

# Installer la CA dans le trust store système
docker exec laradock_frankenphp caddy trust
```

## 🎯 Avantages du Système de Switch

✅ **Flexibilité** : Passez de HTTP à HTTPS en une commande
✅ **Zéro Configuration Manuelle** : Le script gère tout automatiquement
✅ **Certificats Automatiques** : Générés et renouvelés par Caddy en mode HTTPS
✅ **HTTP/2 & HTTP/3** : Activés automatiquement en mode HTTPS
✅ **Pas de Redirect Forcé** : Mode HTTP reste accessible sans redirection
✅ **Développement Réaliste** : Testez en HTTP simple ou HTTPS comme en production

## 🔍 Troubleshooting

### Le script ne trouve pas les fichiers Caddyfile

**Cause** : Vous n'êtes pas dans le bon répertoire

**Solution** :
```bash
# Lancez le script depuis la racine du projet
cd /home/kev/Documents/lab/sites/boilerplate/laradock-lite
./scripts/frankenphp-https.sh status
```

### "Certificat non valide" dans le navigateur (mode HTTPS)

**Normal** : Certificat auto-signé pour développement local.

**Solutions** :
1. Acceptez l'exception dans le navigateur (recommandé pour dev)
2. Installez la CA Caddy dans votre trust store système :
   ```bash
   docker exec laradock_frankenphp caddy trust
   ```

### HTTP redirige toujours vers HTTPS après avoir désactivé

**Cause** : Cache du navigateur ou cache Caddy

**Solutions** :
```bash
# 1. Nettoyer le cache Caddy (le script le fait déjà)
docker exec laradock_frankenphp rm -rf /data/caddy

# 2. Redémarrer complètement FrankenPHP
docker-compose restart frankenphp

# 3. Vider le cache du navigateur (CTRL+SHIFT+DELETE)
# Ou utiliser le mode navigation privée
```

### "Connection refused" sur HTTPS

**Cause** : FrankenPHP est en mode HTTP uniquement

**Solution** :
```bash
# Vérifier le mode actuel
./scripts/frankenphp-https.sh status

# Activer HTTPS si nécessaire
./scripts/frankenphp-https.sh enable
```

### Nettoyer complètement les certificats

Si vous voulez retirer la CA Caddy de votre système :

```bash
docker exec laradock_frankenphp caddy untrust
```

## 📚 Documentation Officielle

- [FrankenPHP Configuration](https://frankenphp.dev/docs/config/)
- [Caddy Automatic HTTPS](https://caddyserver.com/docs/automatic-https)
- [Caddy Caddyfile](https://caddyserver.com/docs/caddyfile)
