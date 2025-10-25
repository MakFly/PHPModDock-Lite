> [!NOTE]
> This is the English version of the documentation. The content is currently a copy of the French version and needs to be translated.

# 📚 PHPModDock-Lite Documentation - Complete Index

Welcome to the complete documentation for PHPModDock-Lite! This page guides you to the right resource for your needs.

---

## 🚀 Par Où Commencer ?

### Nouveau sur PHPModDock-Lite ?

1. **[README Principal](../README.md)** - Vue d'ensemble et quick start (5 min)
2. **[Pourquoi PHPModDock-Lite ?](WHY_PHPMODDOCK.md)** - Comparaison avec Laradock original (10 min)
3. **[Guide Workspace](guides/WORKSPACE_GUIDE.md)** - Comprendre le workspace intelligent (15 min)

### Prêt à Créer un Projet ?

**→ [Guide Création de Projets](guides/NEW_PROJECT_GUIDE.md)** - Créer automatiquement des projets Laravel/Symfony

---

## 📖 Documentation par Catégorie

### 🎓 Guides (Step-by-Step)

Guides pratiques pour accomplir des tâches spécifiques.

| Guide | Description | Durée | Niveau |
|-------|-------------|-------|--------|
| **[Workspace Multi-Projet](guides/WORKSPACE_GUIDE.md)** | Menu interactif, navigation, aliases intelligents | 15 min | ⭐ Débutant |
| **[Création de Projets](guides/NEW_PROJECT_GUIDE.md)** | Scripts automatiques multi-OS, création Laravel/Symfony | 20 min | ⭐ Débutant |
| **[Configuration HTTPS](guides/FRANKENPHP_HTTPS_SETUP.md)** | Switch HTTP/HTTPS, certificats automatiques | 10 min | ⭐⭐ Intermédiaire |
| **[Multi-Projet FrankenPHP](guides/FRANKENPHP_MULTI_PROJECT.md)** | Architecture instance unique, gestion simultanée | 15 min | ⭐⭐ Intermédiaire |

### 📘 Références Techniques

Documentation technique approfondie pour configuration avancée.

| Référence | Description | Niveau |
|-----------|-------------|--------|
| **[FrankenPHP](reference/FRANKENPHP.md)** | Serveur PHP moderne, worker mode, performance | ⭐⭐⭐ Avancé |
| **[Caddyfile](reference/CADDYFILE.md)** | Configuration Caddy, directives, customisation | ⭐⭐⭐ Avancé |

### 🛠️ Scripts & Outils

| Script | Description | Documentation |
|--------|-------------|---------------|
| **new-project.sh** | Création automatique de projets | [Guide Projets](guides/NEW_PROJECT_GUIDE.md) + [Scripts README](../scripts/README.md) |
| **hosts-manager.sh** | Gestion /etc/hosts multi-OS | [Guide Projets](guides/NEW_PROJECT_GUIDE.md) + [Scripts README](../scripts/README.md) |
| **frankenphp-https.sh** | Switch HTTP/HTTPS | [Guide HTTPS](guides/FRANKENPHP_HTTPS_SETUP.md) + [Scripts README](../scripts/README.md) |

### 📝 Tutoriels (À Venir)

| Tutoriel | Description | Statut |
|----------|-------------|--------|
| Laravel + Vite + TailwindCSS | Setup complet frontend moderne | 🚧 Planifié |
| Symfony API Platform | API REST complète | 🚧 Planifié |
| Laravel Octane + FrankenPHP | Performance maximale | 🚧 Planifié |
| Multi-Tenant avec PHPModDock-Lite | Architecture multi-tenants | 🚧 Planifié |

---

## 🎯 Par Cas d'Usage

### Je veux...

#### Démarrer un Nouveau Projet Laravel

1. [Quick Start](../README.md#quick-start) (2 min)
2. [Créer le projet](guides/NEW_PROJECT_GUIDE.md#laravel) (5 min)
3. [Utiliser le workspace](guides/WORKSPACE_GUIDE.md#workflow-1--développement-laravel) (10 min)

**Temps total** : ~15-20 minutes

#### Démarrer un Nouveau Projet Symfony

1. [Quick Start](../README.md#quick-start) (2 min)
2. [Créer le projet](guides/NEW_PROJECT_GUIDE.md#symfony) (5 min)
3. [Utiliser le workspace](guides/WORKSPACE_GUIDE.md#workflow-2--développement-symfony) (10 min)

**Temps total** : ~15-20 minutes

#### Activer HTTPS pour le Développement

**→ [Guide HTTPS](guides/FRANKENPHP_HTTPS_SETUP.md)** (10 min)

#### Gérer Plusieurs Projets Simultanément

**→ [Guide Multi-Projet](guides/FRANKENPHP_MULTI_PROJECT.md)** (15 min)

#### Optimiser les Performances

**→ [Référence FrankenPHP - Worker Mode](reference/FRANKENPHP.md)** (20 min)

#### Configurer Caddy/FrankenPHP Avancé

**→ [Référence Caddyfile](reference/CADDYFILE.md)** (30 min)

#### Comprendre Pourquoi Choisir PHPModDock-Lite

**→ [Pourquoi PHPModDock-Lite ?](WHY_PHPMODDOCK.md)** (15 min)

---

## 🖥️ Par Système d'Exploitation

### Linux

Tout fonctionne nativement ! Suivez la documentation standard.

**Particularités** :
- Utiliser `sudo` pour les scripts de modification système
- Chemin hosts : `/etc/hosts`

**→ [Guide Projets - Section Linux](guides/NEW_PROJECT_GUIDE.md#linux)**

### macOS

Fonctionne comme Linux avec quelques spécificités.

**Particularités** :
- Utiliser `sudo` (mot de passe macOS demandé)
- Permissions Docker parfois à vérifier
- Chemin hosts : `/etc/hosts`

**→ [Guide Projets - Section macOS](guides/NEW_PROJECT_GUIDE.md#macos)**

### Windows (Git Bash)

Supporté avec scripts adaptés !

**Particularités** :
- Lancer Git Bash en Administrateur
- Chemin hosts : `C:/Windows/System32/drivers/etc/hosts`
- Alternative : Modification manuelle

**→ [Guide Projets - Section Windows](guides/NEW_PROJECT_GUIDE.md#windows-git-bash)**

### WSL (Windows Subsystem for Linux)

Détection automatique et support complet.

**Particularités** :
- Fichier hosts Windows accessible via `/mnt/c/`
- Utiliser `sudo` comme sous Linux
- Fonctionne depuis Ubuntu/Debian WSL

**→ [Guide Projets - Section WSL](guides/NEW_PROJECT_GUIDE.md#wsl-windows-subsystem-for-linux)**

---

## 📚 Par Framework

### Laravel

**Guides Recommandés** :
1. [Création Projet Laravel](guides/NEW_PROJECT_GUIDE.md#laravel)
2. [Workflow Laravel](guides/WORKSPACE_GUIDE.md#workflow-1--développement-laravel)
3. [Laravel Octane + FrankenPHP](reference/FRANKENPHP.md) (performance)

**Commandes Utiles** :
```bash
# Créer projet
sudo ./scripts/new-project.sh laravel my-app

# Workspace
make workspace → Choisir Laravel
art migrate
pest
```

### Symfony

**Guides Recommandés** :
1. [Création Projet Symfony](guides/NEW_PROJECT_GUIDE.md#symfony)
2. [Workflow Symfony](guides/WORKSPACE_GUIDE.md#workflow-2--développement-symfony)
3. [Symfony Runtime + FrankenPHP](reference/FRANKENPHP.md) (performance)

**Commandes Utiles** :
```bash
# Créer projet
sudo ./scripts/new-project.sh symfony my-api

# Workspace
make workspace → Choisir Symfony
sf cache:clear
sf make:entity
```

---

## 🔍 Par Niveau d'Expertise

### ⭐ Débutant

**Parcours Recommandé** :

1. **[README Principal](../README.md)** (5 min) - Vue d'ensemble
2. **[Installation](../README.md#installation)** (2 min) - Setup
3. **[Premier Projet](guides/NEW_PROJECT_GUIDE.md)** (10 min) - Créer Laravel/Symfony
4. **[Workspace Basique](guides/WORKSPACE_GUIDE.md#accès-au-workspace)** (5 min) - Utilisation quotidienne

**Temps total** : ~25 minutes pour être productif

### ⭐⭐ Intermédiaire

**Parcours Recommandé** :

1. **[Multi-Projet](guides/FRANKENPHP_MULTI_PROJECT.md)** (15 min)
2. **[HTTPS Setup](guides/FRANKENPHP_HTTPS_SETUP.md)** (10 min)
3. **[Workspace Avancé](guides/WORKSPACE_GUIDE.md#helpers-universels)** (15 min)
4. **[Scripts Automation](../scripts/README.md)** (10 min)

**Temps total** : ~50 minutes

### ⭐⭐⭐ Avancé

**Parcours Recommandé** :

1. **[FrankenPHP Référence](reference/FRANKENPHP.md)** (30 min)
2. **[Caddyfile Configuration](reference/CADDYFILE.md)** (30 min)
3. **[Worker Mode & Performance](reference/FRANKENPHP.md#worker-mode)** (20 min)
4. **[Customisation Avancée](reference/CADDYFILE.md#advanced-customization)** (20 min)

**Temps total** : ~1h40

---

## 🆘 Troubleshooting

### Problèmes Fréquents

| Problème | Solution | Documentation |
|----------|----------|---------------|
| Container ne démarre pas | Vérifier Docker, ports occupés | [README - Troubleshooting](../README.md) |
| /etc/hosts non modifié | Privilèges admin requis | [Guide Projets - Privilèges](guides/NEW_PROJECT_GUIDE.md#gestion-des-privilèges-par-os) |
| Workspace menu absent | Rebuild workspace | [Workspace - Setup](guides/WORKSPACE_GUIDE.md) |
| HTTPS ne fonctionne pas | Vérifier mode, Caddyfile | [Guide HTTPS - Troubleshooting](guides/FRANKENPHP_HTTPS_SETUP.md#troubleshooting) |
| Performance faible | Activer worker mode | [FrankenPHP - Performance](reference/FRANKENPHP.md) |

### Support

- **Issues GitHub** : [Ouvrir une issue](https://github.com/your-repo/issues)
- **Documentation** : Vous êtes au bon endroit !
- **Scripts** : `./scripts/<nom>.sh help`

---

## 📊 Référence Rapide

### Commandes Essentielles

```bash
# Installation
make install

# Démarrage
make laravel              # Stack Laravel
make symfony              # Stack Symfony
make minimal              # Services minimum
make full                 # Tous les services

# Workspace
make workspace            # Menu interactif

# Projets
sudo ./scripts/new-project.sh laravel my-app
sudo ./scripts/new-project.sh symfony my-api

# HTTPS
./scripts/frankenphp-https.sh enable
./scripts/frankenphp-https.sh disable

# /etc/hosts
sudo ./scripts/hosts-manager.sh add myapp.localhost
sudo ./scripts/hosts-manager.sh list

# Services
docker-compose ps         # État des services
docker-compose logs -f    # Logs en temps réel
make logs                 # Logs (via Makefile)
```

### Helpers Workspace

```bash
# Navigation
project laravel           # Aller vers Laravel
project symfony           # Aller vers Symfony
project list              # Liste projets

# Exécution
run migrate               # Migrations (auto-détecte framework)
run cache:clear           # Cache clear (auto-détecte)
run test                  # Tests (auto-détecte)

# Info
workspace-info            # Infos complètes
project current           # Projet actuel
```

---

## 🗺️ Plan de la Documentation

```
phpmoddock-lite/
├── README.md                           # 🏠 Point d'entrée principal
├── docs/
│   ├── INDEX.md                        # 📚 Ce fichier
│   ├── WHY_PHPMODDOCK.md              # 🎯 Comparaison Laradock
│   ├── guides/                         # 🎓 Guides pratiques
│   │   ├── WORKSPACE_GUIDE.md         # Workspace intelligent
│   │   ├── NEW_PROJECT_GUIDE.md       # Création projets
│   │   ├── FRANKENPHP_HTTPS_SETUP.md  # Configuration HTTPS
│   │   └── FRANKENPHP_MULTI_PROJECT.md # Multi-projet
│   ├── reference/                      # 📘 Références techniques
│   │   ├── FRANKENPHP.md              # FrankenPHP complet
│   │   └── CADDYFILE.md               # Caddyfile complet
│   └── tutorials/                      # 📝 Tutoriels (à venir)
├── scripts/
│   ├── README.md                       # 🛠️ Documentation scripts
│   ├── new-project.sh                  # Création projets
│   ├── hosts-manager.sh                # Gestion /etc/hosts
│   ├── frankenphp-https.sh            # Switch HTTP/HTTPS
│   └── lib/
│       └── os-detection.sh             # Détection OS
└── services/
    └── [...]                            # Services Docker
```

---

## 🎓 Parcours d'Apprentissage Recommandés

### Parcours 1 : "Je Démarre" (1 heure)

**Objectif** : Créer votre premier projet et être productif

1. [README](../README.md) - Quick Start (5 min)
2. [Installer](../README.md#installation) (2 min)
3. [Premier Projet](guides/NEW_PROJECT_GUIDE.md#exemples-pratiques) (15 min)
4. [Workspace Basique](guides/WORKSPACE_GUIDE.md#accès-au-workspace) (10 min)
5. **Pratique** : Créer un vrai projet (30 min)

### Parcours 2 : "Je Maîtrise" (3 heures)

**Objectif** : Devenir expert PHPModDock-Lite

1. Parcours 1 complet (1h)
2. [Multi-Projet](guides/FRANKENPHP_MULTI_PROJECT.md) (30 min)
3. [HTTPS](guides/FRANKENPHP_HTTPS_SETUP.md) (20 min)
4. [Workspace Avancé](guides/WORKSPACE_GUIDE.md) (30 min)
5. [Scripts](../scripts/README.md) (20 min)
6. **Pratique** : 2-3 projets simultanés (30 min)

### Parcours 3 : "Je Performe" (5 heures)

**Objectif** : Extraction maximale de performance

1. Parcours 2 complet (3h)
2. [FrankenPHP Complet](reference/FRANKENPHP.md) (1h)
3. [Worker Mode](reference/FRANKENPHP.md#worker-mode) (30 min)
4. [Caddyfile Avancé](reference/CADDYFILE.md) (1h)
5. **Pratique** : Benchmarks et optimisation (30 min)

---

## 🌟 Contributions

La documentation est vivante et s'améliore grâce à la communauté !

**Comment contribuer** :
1. Trouvez une typo/erreur → Ouvrez une issue
2. Manque une info → Proposez un ajout
3. Cas d'usage intéressant → Partagez-le !

---

## 📱 Liens Rapides

| Ressource | Lien |
|-----------|------|
| **README Principal** | [README.md](../README.md) |
| **Pourquoi Lite ?** | [WHY_PHPMODDOCK.md](WHY_PHPMODDOCK.md) |
| **Guides** | [docs/guides/](guides/) |
| **Références** | [docs/reference/](reference/) |
| **Scripts** | [scripts/README.md](../scripts/README.md) |
| **GitHub** | [Repository](https://github.com/your-repo) |

---

**Bonne Documentation !** 🚀

*Dernière mise à jour : Octobre 2025*