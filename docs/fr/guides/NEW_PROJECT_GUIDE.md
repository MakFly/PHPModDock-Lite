# Guide de Création de Nouveaux Projets

## 🚀 Vue d'Ensemble

Laradock Lite inclut un système automatisé de création de projets qui :
- ✅ Détecte automatiquement votre OS (Linux / macOS / Windows / WSL)
- ✅ Crée le projet Laravel ou Symfony
- ✅ Configure automatiquement le Caddyfile
- ✅ Met à jour `/etc/hosts` avec les bons privilèges
- ✅ Redémarre FrankenPHP
- ✅ Fournit les prochaines étapes

## 📋 Script Principal : `new-project.sh`

### Utilisation Basique

```bash
# Laravel standard
./scripts/new-project.sh laravel my-app

# Symfony webapp
./scripts/new-project.sh symfony my-api
```

### Commande Complète

```bash
./scripts/new-project.sh <framework> <nom-projet> [options]
```

**Frameworks supportés** :
- `laravel` - Projet Laravel complet
- `symfony` - Projet Symfony

**Options** :
- `--domain <domain>` - Domaine personnalisé (défaut: `<nom-projet>.localhost`)
- `--no-hosts` - Ne pas modifier `/etc/hosts` (configuration manuelle)
- `--no-caddyfile` - Ne pas modifier le Caddyfile
- `--skeleton` - Symfony : utiliser skeleton au lieu de webapp
- `--api` - Laravel : API-only / Symfony : API Platform

---

## 🎯 Exemples Pratiques

### Laravel

#### Projet Laravel Standard
```bash
./scripts/new-project.sh laravel shop

# Résultat:
# ✓ Projet créé dans projects/shop/
# ✓ Accessible sur http://shop.localhost
# ✓ Entrée /etc/hosts ajoutée
# ✓ Caddyfile configuré
```

#### Laravel API-Only
```bash
./scripts/new-project.sh laravel api-backend --api

# Inclut:
# - Laravel Sanctum pré-installé
# - Configuration API optimisée
```

#### Avec Domaine Personnalisé
```bash
./scripts/new-project.sh laravel boutique --domain shop.local

# Accessible sur http://shop.local
```

### Symfony

#### Symfony Webapp (Full-Stack)
```bash
./scripts/new-project.sh symfony blog

# Inclut:
# - Twig, Doctrine, Forms, Security
# - Tous les composants pour application web complète
```

#### Symfony Skeleton (Minimal)
```bash
./scripts/new-project.sh symfony microservice --skeleton

# Version minimale pour microservices/APIs
```

#### Symfony API Platform
```bash
./scripts/new-project.sh symfony api-rest --api

# Inclut:
# - API Platform pré-installé
# - Configuration REST optimisée
```

---

## 🖥️ Gestion Multi-OS du `/etc/hosts`

### Script : `hosts-manager.sh`

Le script `hosts-manager.sh` gère intelligemment le fichier hosts selon votre OS.

#### Détection Automatique de l'OS

```bash
./scripts/hosts-manager.sh info

# Affiche:
# - Type d'OS (Linux / macOS / Windows / WSL)
# - Chemin du fichier hosts
# - Privilèges actuels
```

**Chemins détectés automatiquement** :
- **Linux / macOS** : `/etc/hosts`
- **Windows (Git Bash)** : `C:/Windows/System32/drivers/etc/hosts`
- **WSL** : `/mnt/c/Windows/System32/drivers/etc/hosts`

#### Commandes Disponibles

##### Ajouter une Entrée

```bash
# Linux / macOS
sudo ./scripts/hosts-manager.sh add myapp.localhost

# Windows (Git Bash en Administrateur)
./scripts/hosts-manager.sh add myapp.localhost

# Avec IP et commentaire personnalisés
sudo ./scripts/hosts-manager.sh add myapp.localhost 127.0.0.1 "Mon Application"
```

##### Supprimer une Entrée

```bash
# Linux / macOS
sudo ./scripts/hosts-manager.sh remove myapp.localhost

# Windows
./scripts/hosts-manager.sh remove myapp.localhost
```

##### Ajouter Plusieurs Entrées (Gérées)

```bash
# Format: domain:ip:comment
sudo ./scripts/hosts-manager.sh add-managed \
    "laravel-app.localhost::Laravel Project" \
    "symfony-api.localhost::Symfony API" \
    "shop.localhost::E-commerce"
```

Cette commande crée une section gérée dans le fichier hosts :

```
# BEGIN Laradock Lite - Auto-generated
127.0.0.1	laravel-app.localhost	# Laravel Project
127.0.0.1	symfony-api.localhost	# Symfony API
127.0.0.1	shop.localhost	# E-commerce
# END Laradock Lite
```

##### Lister les Entrées

```bash
./scripts/hosts-manager.sh list
```

##### Vérifier une Entrée

```bash
./scripts/hosts-manager.sh check myapp.localhost

# Retour:
# ✓ L'entrée existe: myapp.localhost
# 127.0.0.1	myapp.localhost
```

---

## 🔐 Gestion des Privilèges par OS

### Linux

```bash
# Option 1: Avec sudo (recommandé)
sudo ./scripts/new-project.sh laravel my-app

# Option 2: Désactiver modification hosts
./scripts/new-project.sh laravel my-app --no-hosts
# Puis ajouter manuellement:
sudo ./scripts/hosts-manager.sh add my-app.localhost
```

**Ce qui se passe** :
- ✅ Détection automatique de Linux
- ✅ Utilise `sudo` pour modifier `/etc/hosts`
- ✅ Backup automatique du fichier hosts

### macOS

```bash
# Identique à Linux
sudo ./scripts/new-project.sh symfony my-api
```

**Ce qui se passe** :
- ✅ Détection automatique de macOS
- ✅ Demande mot de passe macOS pour sudo
- ✅ Backup automatique du fichier hosts

### Windows (Git Bash)

**Option 1 : Lancer Git Bash en Administrateur** (recommandé)

1. Clic droit sur **Git Bash**
2. Choisir **Exécuter en tant qu'administrateur**
3. Lancer le script normalement :

```bash
./scripts/new-project.sh laravel my-app
```

**Option 2 : Sans privilèges administrateur**

```bash
# Créer le projet sans modifier hosts
./scripts/new-project.sh laravel my-app --no-hosts
```

Puis modifier manuellement `C:\Windows\System32\drivers\etc\hosts` :
1. Ouvrir **Notepad** en tant qu'administrateur
2. Ouvrir `C:\Windows\System32\drivers\etc\hosts`
3. Ajouter : `127.0.0.1  my-app.localhost`

### WSL (Windows Subsystem for Linux)

WSL peut modifier le fichier hosts Windows directement :

```bash
# Le script détecte automatiquement WSL
sudo ./scripts/new-project.sh symfony api
```

**Ce qui se passe** :
- ✅ Détection automatique de WSL
- ✅ Modification du fichier hosts Windows via `/mnt/c/`
- ✅ Fonctionne depuis Ubuntu/Debian WSL

**Si problèmes de permissions** :

```bash
# Créer le projet sans hosts
./scripts/new-project.sh symfony api --no-hosts

# Puis via PowerShell Administrateur sur Windows :
# Modifier C:\Windows\System32\drivers\etc\hosts
```

---

## 📚 Workflow Complet

### Création d'un Nouveau Projet Laravel

```bash
# 1. Créer le projet
sudo ./scripts/new-project.sh laravel shop

# 2. Configuration affichée automatiquement
#    - URL : http://shop.localhost
#    - Chemin : projects/shop/

# 3. Accéder au workspace
make workspace

# 4. Choisir le projet dans le menu
[Sélectionner shop dans le menu]

# 5. Configurer la base de données
nano .env
# Modifier DB_DATABASE, DB_USERNAME, DB_PASSWORD

# 6. Lancer les migrations
art migrate

# 7. Installer et compiler les assets
npm install
npm run dev

# 8. Ouvrir dans le navigateur
# http://shop.localhost
```

### Création d'un Nouveau Projet Symfony

```bash
# 1. Créer le projet
sudo ./scripts/new-project.sh symfony blog --api

# 2. Accéder au workspace
make workspace

# 3. Choisir le projet
[Sélectionner blog dans le menu]

# 4. Configurer la base de données
nano .env
# Modifier DATABASE_URL

# 5. Créer une entité
sf make:entity Article

# 6. Générer et exécuter les migrations
sf make:migration
sf doctrine:migrations:migrate

# 7. Ouvrir dans le navigateur
# http://blog.localhost
```

---

## 🔧 Cas Particuliers

### Plusieurs Projets Simultanés

```bash
# Créer plusieurs projets
sudo ./scripts/new-project.sh laravel admin
sudo ./scripts/new-project.sh laravel shop
sudo ./scripts/new-project.sh symfony api

# Tous accessibles simultanément:
# http://admin.localhost
# http://shop.localhost
# http://api.localhost
```

### Utiliser un Domaine Non-.localhost

```bash
# Avec domaine custom
sudo ./scripts/new-project.sh laravel site --domain monsite.local

# N'oubliez pas d'ajouter aussi à /etc/hosts
sudo ./scripts/hosts-manager.sh add monsite.local
```

### Configuration Manuelle (Sans Scripts)

Si vous préférez tout faire manuellement :

```bash
# 1. Créer le projet sans automation
./scripts/new-project.sh laravel my-app --no-hosts --no-caddyfile

# 2. Modifier Caddyfile manuellement
nano services/frankenphp/config/Caddyfile
# Ajouter le bloc serveur

# 3. Modifier /etc/hosts manuellement
sudo nano /etc/hosts
# Ajouter: 127.0.0.1  my-app.localhost

# 4. Redémarrer FrankenPHP
docker-compose restart frankenphp
```

---

## ⚠️ Troubleshooting

### Erreur : Privilèges Insuffisants

**Symptôme** :
```
✗ Privilèges administrateur requis
```

**Solution** :
- **Linux/macOS** : Relancez avec `sudo`
- **Windows** : Lancez Git Bash en tant qu'Administrateur
- **Alternative** : Utilisez `--no-hosts` et modifiez manuellement

### Erreur : Docker Non Démarré

**Symptôme** :
```
✗ Docker n'est pas démarré
```

**Solution** :
- Démarrez Docker Desktop
- Relancez le script

### Erreur : Projet Existe Déjà

**Symptôme** :
```
✗ Le projet existe déjà: projects/my-app
```

**Solution** :
- Choisissez un autre nom
- OU supprimez le projet existant :
```bash
rm -rf projects/my-app
./scripts/new-project.sh laravel my-app
```

### Domaine Non Accessible

**Causes possibles** :

1. **Entrée /etc/hosts manquante**
   ```bash
   ./scripts/hosts-manager.sh check my-app.localhost
   # Si absent:
   sudo ./scripts/hosts-manager.sh add my-app.localhost
   ```

2. **Caddyfile non configuré**
   ```bash
   # Vérifier Caddyfile
   grep "my-app" services/frankenphp/config/Caddyfile
   ```

3. **FrankenPHP non redémarré**
   ```bash
   docker-compose restart frankenphp
   ```

---

## 📖 Commandes de Référence Rapide

```bash
# Créer un projet
./scripts/new-project.sh <framework> <nom> [options]

# Gérer /etc/hosts
./scripts/hosts-manager.sh add <domain>
./scripts/hosts-manager.sh remove <domain>
./scripts/hosts-manager.sh list
./scripts/hosts-manager.sh check <domain>
./scripts/hosts-manager.sh info

# Vérifier l'OS
./scripts/hosts-manager.sh info
```

---

**Vous avez maintenant un système complet et intelligent pour créer des projets multi-OS !** 🎉
