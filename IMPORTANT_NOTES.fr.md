# ⚠️ NOTES IMPORTANTES - À LIRE AVANT UTILISATION

**Date de mise à jour**: 2025-10-26
**Version**: 0.1.0

---

## 🔴 POINTS CRITIQUES À CONNAÎTRE

### 1. **FrankenPHP: Rebuild OBLIGATOIRE après modification du Caddyfile**

Le fichier `services/frankenphp/config/Caddyfile` est **copié dans l'image Docker au moment du build**, pas monté comme un volume.

**❌ ERREUR COMMUNE:**
```bash
# Modifier le Caddyfile
nano services/frankenphp/config/Caddyfile

# Redémarrer FrankenPHP
docker-compose restart frankenphp  # ❌ LES CHANGEMENTS NE SONT PAS PRIS EN COMPTE !
```

**✅ PROCÉDURE CORRECTE:**
```bash
# 1. Modifier le Caddyfile
nano services/frankenphp/config/Caddyfile

# 2. Rebuild l'image FrankenPHP
docker-compose build frankenphp

# 3. Redémarrer le container
docker-compose up -d frankenphp
```

**Pourquoi?** Le Dockerfile contient:
```dockerfile
COPY config/Caddyfile /etc/frankenphp/Caddyfile  # Ligne 145
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]  # Ligne 154
```

---

### 2. **Détection Automatique des Projets**

Les projets dans `./projects/` sont **automatiquement détectés** et affichés sur la page d'accueil.

**Comment ça marche:**
1. L'API `/api/projects.php` scanne `/var/www` (monté depuis `./projects`)
2. Détecte automatiquement le framework (Laravel, Symfony, PrestaShop, WordPress)
3. Affiche les projets avec icônes et couleurs appropriées

**Pour actualiser la liste SANS recharger la page:**
- Cliquez sur le bouton **"Actualiser"** en haut à droite de la section "Your Projects"

**Frameworks détectés:**
- **Laravel**: `artisan` + `bootstrap/app.php`
- **Symfony**: `symfony.lock` + `bin/console`
- **PrestaShop**: `classes/PrestaShopAutoload.php` + `modules`
- **WordPress**: `wp-config.php` + `wp-content`

---

### 3. **Création de Projet PrestaShop**

PrestaShop est maintenant supporté ! Utilisation:

```bash
./scripts/new-project.sh prestashop my-shop
```

**Ce que fait le script:**
1. Télécharge PrestaShop 8.2.0 depuis GitHub
2. Extrait les fichiers (double extraction nécessaire: ZIP dans ZIP)
3. Configure les permissions (777 sur certains dossiers)
4. Ajoute la configuration au Caddyfile
5. Ajoute l'entrée dans `/etc/hosts`
6. **Rebuild automatiquement FrankenPHP**

**Accès:** `http://my-shop.localhost`

**Configuration de la base de données:**
- Serveur: `mysql`
- Base de données: `default` (ou créez-en une via Adminer)
- Utilisateur: `default`
- Mot de passe: `secret`

---

### 4. **Fichiers HTML Hot-Reload**

Les fichiers HTML sont maintenant **montés en lecture seule** pour permettre les modifications à chaud:

```yaml
# docker-compose.yml
frankenphp:
  volumes:
    - ./services/frankenphp/html:/usr/share/frankenphp/html:ro  # :ro = read-only

nginx:
  volumes:
    - ./services/nginx/html:/usr/share/nginx/html:ro
```

**Résultat:** Vous pouvez modifier `index.html` et voir les changements **immédiatement** sans rebuild !

---

### 5. **Ports des Services**

**⚠️ ATTENTION:** Les ports ont été corrigés pour éviter les conflits:

| Service | Port | URL |
|---------|------|-----|
| **FrankenPHP** | 80, 443 | `http://localhost` |
| **Nginx** | 8080, 8443 | `http://localhost:8080` |
| **Adminer** | **8081** | `http://localhost:8081` |
| **Redis Commander** | **8082** | `http://localhost:8082` |
| **Mailhog** | 8025 | `http://localhost:8025` |
| **Dozzle** | 8888 | `http://localhost:8888` |
| **RabbitMQ** | 15672 | `http://localhost:15672` |
| **Meilisearch** | 7700 | `http://localhost:7700` |

**Changement majeur:** Adminer sur 8081 (avant: 8082), Redis Commander sur 8082 (avant: conflit)

---

### 6. **Quick Start: Deux Modes**

Le script `./quick-start.sh` propose maintenant **2 modes**:

#### **Mode 1: Fresh Installation** (nouveau projet)
```bash
./quick-start.sh
# Choisir: 1) Fresh installation
# Choisir PHP version
# Choisir framework (Laravel/Symfony/PrestaShop)
# → Projet créé automatiquement
```

#### **Mode 2: Git Clone Setup** (projet existant)
```bash
git clone https://github.com/user/phpmoddock-lite.git
cd phpmoddock-lite

# Cloner votre projet existant
git clone https://github.com/user/my-laravel-app.git projects/my-app

# Lancer le setup
./quick-start.sh
# Choisir: 2) Git clone setup
# → Détecte automatiquement le framework
# → Guide pour configuration Caddyfile + hosts
```

---

### 7. **Workflow Recommandé pour Ajouter un Projet**

**Option A: Via Script (Recommandé)**
```bash
./scripts/new-project.sh laravel my-new-app
# ✅ Tout est configuré automatiquement
```

**Option B: Projet Existant**
```bash
# 1. Copier/cloner dans projects/
cp -r ~/my-existing-app ./projects/my-app

# 2. Ajouter au Caddyfile
nano services/frankenphp/config/Caddyfile
# Ajouter le bloc serveur approprié

# 3. Rebuild FrankenPHP (CRITIQUE!)
docker-compose build frankenphp
docker-compose up -d frankenphp

# 4. Ajouter au /etc/hosts
./scripts/hosts-manager.sh add my-app.localhost
```

---

### 8. **Health Check des Services**

La page d'accueil affiche l'**état en temps réel** de chaque service:

- 🟢 **Vert pulsant** = Service actif
- 🔴 **Rouge** = Service down
- ⚪ **Gris** = Vérification en cours

**Auto-refresh:** Toutes les 30 secondes
**Technique:** Utilise `fetch()` avec mode `no-cors` pour tester les ports

---

## 🔒 Sécurité pour Développeurs Nomades

**⚠️ ATTENTION**: Si vous travaillez depuis des cafés, coworking, ou WiFi publics:

### 1. **Ports Exposés Uniquement en Local**

Par défaut, PHPModDock-Lite expose tous les ports sur `127.0.0.1` (localhost uniquement):

```yaml
# docker-compose.yml - Configuration sécurisée
mysql:
  ports:
    - "127.0.0.1:3306:3306"  # ✅ Accessible uniquement depuis votre machine

# Configuration DANGEREUSE à éviter:
mysql:
  ports:
    - "3306:3306"  # ❌ Accessible depuis tout le réseau local !
```

**Pourquoi c'est important:**
- Sur WiFi public, `0.0.0.0:3306` = exposé à tous les clients du réseau
- Quelqu'un sur le même WiFi pourrait scanner les ports et tenter de se connecter
- Avec les mots de passe par défaut, c'est une faille de sécurité majeure

### 2. **Changez les Mots de Passe par Défaut**

Le fichier `.env.example` contient des mots de passe marqués `CHANGE_ME_`:

```bash
# .env
MYSQL_PASSWORD=CHANGE_ME_secret         # ⚠️ À changer immédiatement !
MYSQL_ROOT_PASSWORD=CHANGE_ME_root      # ⚠️ À changer immédiatement !
POSTGRES_PASSWORD=CHANGE_ME_secret      # ⚠️ À changer immédiatement !
RABBITMQ_DEFAULT_PASS=CHANGE_ME_guest   # ⚠️ À changer immédiatement !
```

**Générer des mots de passe forts:**
```bash
# Linux/macOS
openssl rand -hex 16

# Ou utiliser un gestionnaire de mots de passe
```

### 3. **Pare-feu Personnel Recommandé**

Sur macOS/Linux, activez votre firewall:

```bash
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Linux (ufw)
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow ssh
```

### 4. **VPN pour Sécurité Maximale**

Sur WiFi public, utilisez **TOUJOURS** un VPN:
- Chiffre tout votre trafic réseau
- Empêche les attaques man-in-the-middle
- Protège contre le sniffing de paquets

### 5. **Vérifiez les Ports Exposés**

Avant de vous connecter à un WiFi public:

```bash
# Vérifier quels ports sont exposés
docker-compose ps

# Vérifier les bindings de ports
docker-compose config | grep ports -A 2

# Tous les ports doivent commencer par "127.0.0.1:"
```

### 6. **HTTPS Uniquement pour les Projets**

FrankenPHP supporte HTTPS automatiquement. Utilisez-le :

```caddyfile
# Caddyfile - HTTPS automatique
https://myapp.localhost {
    # Caddy génère automatiquement les certificats
}
```

---

## 📋 Checklist de Démarrage

Avant de commencer, assurez-vous de:

- [ ] Docker est installé et en cours d'exécution
- [ ] Docker Compose est installé
- [ ] Vous avez les droits sudo (pour /etc/hosts)
- [ ] Le fichier `.env` existe (copié depuis `.env.example`)
- [ ] Les profils sont configurés: `COMPOSE_PROFILES=frankenphp,development`

---

## 🔧 Commandes Essentielles

```bash
# Démarrage
make up                    # Start FrankenPHP stack
make workspace             # Entrer dans le container de dev

# Gestion des projets
./scripts/new-project.sh laravel my-app      # Nouveau Laravel
./scripts/new-project.sh symfony my-api      # Nouveau Symfony
./scripts/new-project.sh prestashop my-shop  # Nouveau PrestaShop

# Après modification Caddyfile
docker-compose build frankenphp
docker-compose up -d frankenphp

# Gestion hosts
./scripts/hosts-manager.sh add myapp.localhost
./scripts/hosts-manager.sh list
./scripts/hosts-manager.sh remove myapp.localhost

# Logs
make logs                  # Tous les logs
docker-compose logs -f frankenphp  # Logs FrankenPHP uniquement
```

---

## ⚡ Troubleshooting Rapide

### Problème: Page blanche sur mon projet
**Cause probable:** Caddyfile modifié mais pas rebuild
**Solution:**
```bash
docker-compose build frankenphp
docker-compose up -d frankenphp
```

### Problème: "Connection refused" sur un service
**Solution:**
1. Vérifier que le service est démarré: `docker-compose ps`
2. Vérifier les logs: `docker-compose logs <service>`
3. Redémarrer: `docker-compose restart <service>`

### Problème: Projet non visible sur http://localhost
**Solution:**
1. Cliquer sur "Actualiser" dans la section "Your Projects"
2. Vérifier que le projet est dans `./projects/`
3. Vérifier les logs de l'API: `curl http://localhost/api/projects.php`

### Problème: Permission denied dans le container
**Solution:**
```bash
# Dans le workspace
cd /var/www/my-project
chmod -R 775 storage bootstrap/cache  # Laravel
chmod -R 775 var/                      # Symfony
```

---

## 📚 Documentation Complémentaire

- **README.md**: Vue d'ensemble et quick start
- **CHANGELOG.md**: Historique des changements
- **docs/**: Documentation complète (anglais + français)
  - `docs/en/guides/NEW_PROJECT_GUIDE.md`
  - `docs/fr/guides/FRANKENPHP_MULTI_PROJECT.md`

---

## 🆘 Support

Si vous rencontrez un problème:

1. Consultez ce fichier en premier
2. Vérifiez le CHANGELOG.md pour les changements récents
3. Lisez les logs: `docker-compose logs`
4. Ouvrez une issue sur GitHub avec:
   - Version de Docker / Docker Compose
   - OS utilisé
   - Logs complets de l'erreur

---

**Dernière mise à jour:** 2025-10-26 - Version 0.1.0
