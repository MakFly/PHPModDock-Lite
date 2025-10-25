# Scripts PHPModDock-Lite

Collection de scripts utilitaires pour gérer votre environnement PHPModDock-Lite.

## 📜 Scripts Disponibles

### 🆕 `new-project.sh` - Création Automatique de Projets

Crée automatiquement un nouveau projet Laravel ou Symfony avec configuration complète.

**Utilisation** :
```bash
# Laravel standard
./scripts/new-project.sh laravel my-app

# Symfony webapp
./scripts/new-project.sh symfony my-api

# Laravel API
./scripts/new-project.sh laravel api-backend --api

# Symfony skeleton
./scripts/new-project.sh symfony microservice --skeleton

# Avec domaine custom
./scripts/new-project.sh laravel shop --domain boutique.local

# Sans modifier /etc/hosts
./scripts/new-project.sh symfony api --no-hosts
```

**Fonctionnalités** :
- ✅ Détection automatique OS (Linux / macOS / Windows / WSL)
- ✅ Création du projet dans `projects/`
- ✅ Configuration automatique du Caddyfile
- ✅ Mise à jour intelligente de `/etc/hosts`
- ✅ Redémarrage de FrankenPHP
- ✅ Instructions personnalisées selon le framework

**Documentation** : Voir `../NEW_PROJECT_GUIDE.md`

---

### 🌐 `hosts-manager.sh` - Gestion Intelligente de /etc/hosts

Gère le fichier hosts de manière intelligente selon votre OS.

**Commandes** :
```bash
# Informations OS et fichier hosts
./scripts/hosts-manager.sh info

# Ajouter une entrée (nécessite sudo sur Linux/macOS)
sudo ./scripts/hosts-manager.sh add myapp.localhost

# Supprimer une entrée
sudo ./scripts/hosts-manager.sh remove myapp.localhost

# Ajouter plusieurs entrées gérées
sudo ./scripts/hosts-manager.sh add-managed \
    "laravel-app.localhost::Laravel" \
    "symfony-api.localhost::Symfony"

# Lister les entrées
./scripts/hosts-manager.sh list

# Vérifier si une entrée existe
./scripts/hosts-manager.sh check laravel-app.localhost
```

**Fonctionnalités** :
- ✅ Détection automatique OS
- ✅ Chemins corrects : `/etc/hosts` (Linux/macOS), `C:/Windows/System32/drivers/etc/hosts` (Windows), `/mnt/c/...` (WSL)
- ✅ Vérification des privilèges
- ✅ Backup automatique avant modification
- ✅ Section gérée avec marqueurs

**Documentation** : Voir `../NEW_PROJECT_GUIDE.md`

---

### 🔐 `frankenphp-https.sh` - Gestion HTTPS FrankenPHP

Switch entre mode HTTP et HTTPS pour FrankenPHP.

**Commandes** :
```bash
# Voir le mode actuel
./scripts/frankenphp-https.sh status

# Activer HTTPS
./scripts/frankenphp-https.sh enable

# Désactiver HTTPS (revenir en HTTP)
./scripts/frankenphp-https.sh disable

# Aide
./scripts/frankenphp-https.sh help
```

**Documentation** : Voir `../FRANKENPHP_HTTPS_SETUP.md`

---

## 📚 Bibliothèques (lib/)

### `os-detection.sh` - Détection Multi-OS

Bibliothèque partagée pour la détection de l'OS et gestion des chemins.

**Fonctions disponibles** :
- `detect_os()` - Détecte l'OS (linux, macos, windows, wsl)
- `get_hosts_file_path()` - Retourne le chemin du fichier hosts
- `check_admin_privileges()` - Vérifie les privilèges admin/sudo
- `backup_hosts_file()` - Crée un backup du fichier hosts
- `print_os_info()` - Affiche les informations OS

**Utilisation dans vos scripts** :
```bash
#!/usr/bin/env bash
source "$(dirname "$0")/lib/os-detection.sh"

# Utiliser les fonctions
OS_TYPE=$(detect_os | cut -d':' -f1)
HOSTS_FILE=$(get_hosts_file_path)
```

---

## 🔧 Utilisation Générale

Tous les scripts doivent être exécutés depuis la **racine du projet** :

```bash
# Bon
cd /path/to/laradock-lite
./scripts/new-project.sh laravel my-app

# Mauvais (ne fonctionnera pas)
cd scripts
./new-project.sh laravel my-app
```

---

## 🖥️ Compatibilité OS

| Script | Linux | macOS | Windows (Git Bash) | WSL |
|--------|-------|-------|-------------------|-----|
| `new-project.sh` | ✅ | ✅ | ✅ | ✅ |
| `hosts-manager.sh` | ✅ | ✅ | ✅ | ✅ |
| `frankenphp-https.sh` | ✅ | ✅ | ✅ | ✅ |

**Note** : Sur Windows et WSL, certaines opérations peuvent nécessiter des privilèges administrateur.

---

## 📚 Documentation

- **Nouveau Projet** : `../NEW_PROJECT_GUIDE.md` ⭐ **NOUVEAU**
- **FrankenPHP HTTPS** : `../FRANKENPHP_HTTPS_SETUP.md`
- **Multi-Projet FrankenPHP** : `../FRANKENPHP_MULTI_PROJECT.md`
- **Workspace Multi-Projet** : `../WORKSPACE_GUIDE.md`
- **README Principal** : `../README.md`

---

## ✨ Contribuer

Pour ajouter un nouveau script :

1. Créez le script dans `scripts/`
2. Rendez-le exécutable : `chmod +x scripts/your-script.sh`
3. Utilisez `lib/os-detection.sh` pour la compatibilité multi-OS
4. Documentez-le dans ce README
5. Créez un guide détaillé si nécessaire dans `../`
