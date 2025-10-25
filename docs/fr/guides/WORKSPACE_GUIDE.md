# Workspace Multi-Projet - Guide d'Utilisation

## 🎯 Vue d'Ensemble

Le workspace Laradock Lite est maintenant **intelligent** et **multi-projet**. Il détecte automatiquement dans quel projet vous travaillez et adapte ses commandes en conséquence.

## 🚀 Accès au Workspace

### Méthode 1 : Via Make (Recommandé)

```bash
make workspace
```

### Méthode 2 : Via Docker Compose

```bash
docker-compose exec -ti workspace bash
```

## 📋 Menu Interactif

Au démarrage, un **menu interactif** apparaît automatiquement :

```
╔════════════════════════════════════════════════════╗
║       Laradock Lite - Workspace Menu              ║
╚════════════════════════════════════════════════════╝

Projets disponibles :

  [1] Laravel [Laravel]
      → /var/www/laravel-app

  [2] Symfony [Symfony]
      → /var/www/symfony-api

  [0] Rester à la racine (/var/www)

Votre choix [0-2]:
```

**Actions** :
- Tapez `1` → Navigation automatique vers Laravel + affichage des commandes disponibles
- Tapez `2` → Navigation automatique vers Symfony + affichage des commandes disponibles
- Tapez `0` → Reste dans `/var/www` (racine)

## 🛠️ Helpers Universels

### Helper `project` - Navigation entre projets

```bash
# Aller vers Laravel
project laravel
# OU
project l

# Aller vers Symfony
project symfony
# OU
project s

# Retour à la racine
project root
# OU
project r

# Lister tous les projets
project list

# Voir le projet actuel
project current
```

**Exemple d'utilisation** :

```bash
# Tu es dans Laravel
/var/www/laravel-app $ art migrate
# Migration OK

# Tu veux aller dans Symfony
/var/www/laravel-app $ project symfony
✓ Switched to Symfony project

# Tu es maintenant dans Symfony
/var/www/symfony-api $ sf cache:clear
# Cache cleared
```

### Helper `run` - Exécution Intelligente

Le helper `run` **détecte automatiquement** le framework et exécute la bonne commande.

```bash
# Migrations (détecte Laravel/Symfony automatiquement)
run migrate

# Cache clear (détecte Laravel/Symfony automatiquement)
run cache:clear

# Tests (détecte Pest/PHPUnit/Symfony tests)
run test

# Composer (universel)
run composer install
run composer require vendor/package

# NPM (universel)
run npm install
run npm run dev
```

**Avantage** : Tu n'as pas besoin de te rappeler si c'est `artisan` ou `bin/console`, le helper le fait pour toi !

### Helper `workspace-info` - Informations Projet

```bash
workspace-info
# OU
ws-info
# OU
wsinfo
```

**Affiche** :
- Répertoire actuel
- Framework détecté (Laravel/Symfony/PHP)
- Version du framework
- Version de PHP, Node.js, Composer
- Commandes rapides disponibles

**Exemple de sortie** :

```
╔════════════════════════════════════════╗
║     Workspace Information              ║
╚════════════════════════════════════════╝

Location:     /var/www/laravel-app
Framework:    Laravel
Version:      Laravel 12.35.1
PHP Version:  8.3.27
Node.js:      v20.11.0
Composer:     2.7.1

Quick commands:
  project list    - List all projects
  project laravel - Switch to Laravel
  project symfony - Switch to Symfony
```

## 🎨 Aliases Contextuels

Les aliases sont maintenant **intelligents** et vérifient que tu es dans le bon projet.

### Aliases Laravel

```bash
art <command>        # Laravel Artisan (vérifie que tu es dans un projet Laravel)
tinker               # Laravel Tinker
migrate              # Migrations (détecte Laravel/Symfony)
migrate-fresh        # Fresh migration avec seed
db-seed              # Database seeder
cache-clear          # Clear cache (détecte Laravel/Symfony)
config-clear         # Clear config
route-clear          # Clear routes
view-clear           # Clear views
optimize             # Optimize
optimize-clear       # Clear optimization
queue-work           # Queue worker
queue-listen         # Queue listener
pest                 # Pest tests
phpunit              # PHPUnit tests
```

### Aliases Symfony

```bash
console <command>    # Symfony Console (vérifie que tu es dans un projet Symfony)
sf <command>         # Raccourci pour Symfony Console
cc                   # Cache clear (détecte Laravel/Symfony)
cw                   # Cache warmup
doctrine             # Doctrine commands
symfony-make         # Symfony Maker Bundle
```

### Aliases Universels (Fonctionnent Partout)

```bash
# Composer
c                    # composer
ci                   # composer install
cu                   # composer update
cr                   # composer require
cda                  # composer dump-autoload
co                   # composer outdated

# NPM
ni                   # npm install
nrd                  # npm run dev
nrb                  # npm run build
nrw                  # npm run watch

# Yarn
yi                   # yarn install
yrd                  # yarn dev
yrb                  # yarn build
yrw                  # yarn watch

# PNPM
pi                   # pnpm install
prd                  # pnpm run dev
prb                  # pnpm run build
prw                  # pnpm run watch

# Git
gs                   # git status
ga                   # git add
gc                   # git commit
gp                   # git push
gl                   # git log (oneline graph)
gco                  # git checkout
gb                   # git branch

# Docker
dc                   # docker-compose
dcu                  # docker-compose up -d
dcd                  # docker-compose down
dcr                  # docker-compose restart
dcl                  # docker-compose logs -f

# Système
ll                   # ls -alF
la                   # ls -A
l                    # ls -CF
fix-perms            # Fix permissions
```

## 🔥 Workflows Typiques

### Workflow 1 : Développement Laravel

```bash
# Entrer dans le workspace
make workspace

# Choisir Laravel (1)
[1] Laravel

# Tu arrives dans /var/www/laravel-app

# Travailler
art migrate
art tinker
pest
npm run dev

# Committer
gs
ga .
gc -m "Add feature"
gp
```

### Workflow 2 : Développement Symfony

```bash
# Entrer dans le workspace
make workspace

# Choisir Symfony (2)
[2] Symfony

# Tu arrives dans /var/www/symfony-api

# Travailler
sf cache:clear
sf make:controller ApiController
composer require symfony/mailer
npm run build

# Committer
gs
ga .
gc -m "Add API controller"
gp
```

### Workflow 3 : Multi-Projet (Switch)

```bash
# Entrer dans le workspace
make workspace

# Choisir Laravel (1)
[1] Laravel

# Travailler sur Laravel
art migrate

# Switcher vers Symfony
project symfony

# Travailler sur Symfony
sf cache:clear

# Retour à Laravel
project laravel

# Continue sur Laravel
art queue:work
```

## ⚠️ Messages d'Erreur Intelligents

Si tu essaies d'utiliser une commande dans le mauvais contexte, tu obtiens un message d'aide :

```bash
# Tu es dans /var/www (racine)
$ art migrate
✗ Not in a Laravel project
💡 Navigate to a Laravel project first: project laravel

# Tu es dans Laravel, tu essaies une commande Symfony
/var/www/laravel-app $ sf cache:clear
✗ Not in a Symfony project
💡 Navigate to a Symfony project first: project symfony
```

## 🎓 Astuces & Bonnes Pratiques

### 1. Utiliser le Helper `project` pour Naviguer

Au lieu de :
```bash
cd /var/www/laravel-app
```

Utilise :
```bash
project laravel
```

**Avantages** :
- Plus court
- Fonctionne de n'importe où
- Affiche les informations du projet

### 2. Utiliser le Helper `run` pour les Commandes Framework

Au lieu de :
```bash
php artisan migrate    # Laravel
php bin/console cache:clear  # Symfony
```

Utilise :
```bash
run migrate
run cache:clear
```

**Avantages** :
- Détection automatique du framework
- Moins de frappe
- Fonctionne pour Laravel ET Symfony

### 3. Vérifier où tu es avec `project current`

```bash
project current
```

Affiche :
- Répertoire actuel
- Framework détecté
- Commandes recommandées

### 4. Lister tous les Projets avec `project list`

```bash
project list
```

Affiche tous les projets PHP disponibles dans `/var/www`

## 🔧 Rebuild du Workspace

Si tu modifies le Dockerfile ou les scripts, rebuild le workspace :

```bash
docker-compose build workspace
docker-compose up -d workspace
```

## 📚 Résumé des Commandes Clés

| Commande | Description |
|----------|-------------|
| `make workspace` | Entrer dans le workspace (menu interactif) |
| `project laravel` | Aller vers Laravel |
| `project symfony` | Aller vers Symfony |
| `project list` | Lister les projets |
| `run migrate` | Migrations (auto-détecte framework) |
| `run cache:clear` | Clear cache (auto-détecte framework) |
| `workspace-info` | Afficher infos projet actuel |
| `art <cmd>` | Laravel Artisan (contextuel) |
| `sf <cmd>` | Symfony Console (contextuel) |

## 🆘 Aide & Support

- **Aide générale** : `project help`
- **Aide helper run** : `run help`
- **Info workspace** : `workspace-info`
- **Liste projets** : `project list`

---

**Bon développement !** 🚀
