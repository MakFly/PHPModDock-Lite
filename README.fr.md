# 🚀 PHPModDock-Lite

**L'environnement Docker moderne pour Laravel, Symfony & PrestaShop** - Simple, Rapide, Puissant.

> Alternative moderne à Laradock : **3-4x plus performant**, setup en **2 minutes**, stack **2025**.

[![PHP 8.4](https://img.shields.io/badge/PHP-8.1%20|%208.2%20|%208.3%20|%208.4-777BB4?style=flat-square&logo=php)](https://www.php.net/)
[![FrankenPHP](https://img.shields.io/badge/FrankenPHP-Latest-00ADD8?style=flat-square)](https://frankenphp.dev/)
[![Laravel](https://img.shields.io/badge/Laravel-10%20|%2011-FF2D20?style=flat-square&logo=laravel)](https://laravel.com/)
[![Symfony](https://img.shields.io/badge/Symfony-6%20|%207-000000?style=flat-square&logo=symfony)](https://symfony.com/)
[![PrestaShop](https://img.shields.io/badge/PrestaShop-8.x-DF0067?style=flat-square&logo=prestashop)](https://www.prestashop.com/)

---

## ✨ Pourquoi PHPModDock-Lite ?

| Laradock (Original) | PHPModDock-Lite | Avantage |
|---------------------|---------------|----------|
| Setup 15-30 min | **Setup 2 min** | ⚡ **7x plus rapide** |
| 150 req/s | **600 req/s** | 🚀 **4x plus performant** |
| 80+ services | **15 services essentiels** | 🎯 **Focalisé** |
| Config manuelle | **Scripts automation** | 🤖 **Intelligent** |
| Technologies 2016 | **Stack 2025** | 🆕 **Moderne** |

**→ [Lire la comparaison complète](docs/WHY_PHPMODDOCK.md)**

---

## 🎯 Fonctionnalités Principales

### Performance Exceptionnelle ⚡

- **FrankenPHP** : Serveur Go ultra-rapide avec worker mode natif
- **HTTP/3 & HTTP/2** : Protocoles modernes activés par défaut
- **Brotli & Gzip** : Compression automatique
- **300%+ Performance** : vs Nginx+PHP-FPM traditionnel

### Developer Experience 🎨

- **Workspace Intelligent** : Menu interactif, aliases contextuels
- **Création Auto** : 1 commande = projet prêt (Laravel/Symfony/PrestaShop)
- **Multi-Projet** : Instance unique servant plusieurs apps
- **Multi-OS** : Linux, macOS, Windows (Git Bash), WSL natif

### Stack Moderne 🆕

- **PHP** : 8.1, 8.2, 8.3, 8.4
- **Node.js** : 18, 20, 22
- **Bases** : MySQL 8, PostgreSQL 16
- **Cache** : Redis, Meilisearch
- **Queue** : RabbitMQ
- **Dev Tools** : Mailhog, Adminer, Dozzle

### Automation 🤖

- ✅ **new-project.sh** - Création projet automatique
- ✅ **hosts-manager.sh** - Gestion /etc/hosts multi-OS
- ✅ **frankenphp-https.sh** - Switch HTTP/HTTPS
- ✅ **Workspace menu** - Navigation intelligente

## Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/phpmoddock-lite.git
cd phpmoddock-lite

# Run installation
make install

# Edit .env to configure your settings
nano .env
```

### 2. Start Your Environment

```bash
# Quick start - FrankenPHP by default (recommended)
make up         # FrankenPHP + essential services

# Interactive web server selection
make dev        # Choose between FrankenPHP or Nginx+PHP-FPM

# Framework-specific shortcuts
make laravel    # Laravel optimized stack (FrankenPHP)
make symfony    # Symfony optimized stack (FrankenPHP)

# Traditional stack
make nginx-stack  # Nginx + PHP-FPM instead of FrankenPHP

# All services
make full       # Everything enabled
```

> **New**: `make dev` provides an interactive menu to choose between FrankenPHP (modern, 3-4x faster) and Nginx+PHP-FPM (traditional).
>
> **Recommended**: Use FrankenPHP (`make up`) for new projects. It's faster, simpler, and supports modern protocols (HTTP/2, HTTP/3).
> See [docs/reference/FRANKENPHP.md](docs/reference/FRANKENPHP.md) for details.

### 3. Setup Your Project

```bash
# Enter workspace container (with interactive menu)
make workspace

# The workspace menu appears - choose your project:
# [1] Laravel  [2] Symfony  [0] Root

# For Laravel - Choose option 1
# You'll be placed in /var/www/laravel-app automatically

# For Symfony - Choose option 2
# You'll be placed in /var/www/symfony-api automatically

# The workspace provides:
# - Contextual aliases (art, sf, etc.)
# - Project navigation helpers
# - Intelligent command detection
```

> **New!** The workspace is now intelligent with:
> - Interactive project selection menu
> - Contextual aliases that adapt to your framework
> - Helper commands: `project laravel`, `project symfony`, `run migrate`
>
> See [WORKSPACE_GUIDE.md](WORKSPACE_GUIDE.md) for complete workspace documentation.

### 4. Configure Web Server

#### FrankenPHP (Recommended)

Update `.env` with your project path:

```bash
SERVER_ROOT=/var/www/my-app/public
```

Enable Laravel or Symfony specific features:

```bash
# For Laravel (Vite HMR, Reverb)
cd services/frankenphp/config/Caddyfile.d
mv laravel.caddyfile.example laravel.caddyfile

# For Symfony (Profiler, Webpack Encore)
cd services/frankenphp/config/Caddyfile.d
mv symfony.caddyfile.example symfony.caddyfile
```

Restart FrankenPHP:
```bash
docker-compose restart frankenphp
```

> See [docs/CADDYFILE.md](docs/CADDYFILE.md) for detailed configuration guide.

#### Nginx + PHP-FPM (Traditional)

```bash
# Copy the appropriate example config
cp services/nginx/sites/laravel.conf.example services/nginx/sites/default.conf
# OR
cp services/nginx/sites/symfony.conf.example services/nginx/sites/default.conf

# Restart Nginx
docker-compose restart nginx
```

### 5. Access Your Application

- **Application**: http://localhost
- **Adminer** (Database UI): http://localhost:8081
- **Mailhog** (Email Testing): http://localhost:8025
- **Redis Commander**: http://localhost:8082
- **Dozzle** (Docker Logs Viewer): http://localhost:8888
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Meilisearch**: http://localhost:7700 (if enabled)
- **Elasticsearch**: http://localhost:9200 (if enabled)

## Available Services

### Core Services (Always Available)
- **workspace**: Development container with PHP CLI, Composer, Node.js, Git

### Web Servers (Choose One)
- **frankenphp** (Recommended): Modern PHP server with HTTP/2, HTTP/3, worker mode
- **nginx + php-fpm** (Traditional): Nginx web server with PHP-FPM

### Database Services
- **mysql** (8.0): MySQL database server
- **postgres** (16): PostgreSQL database server

### Cache & Queue
- **redis** (7): Redis server for cache, sessions, and queues
- **rabbitmq** (3): Message broker with management UI

### Search Engines

**Default: Meilisearch** (Recommended for most projects)
- **meilisearch** (1.24): Lightning-fast search engine, **10x lighter** than Elasticsearch
  - RAM Usage: ~95 MB
  - Perfect for: Small to medium projects, Laravel Scout, development
  - Included in: `laravel`, `symfony`, `full` profiles

**Alternative: Elasticsearch** (For large-scale needs)
- **elasticsearch** (8.11): Enterprise-grade full-text search
  - RAM Usage: ~996 MB
  - Perfect for: Large datasets, complex queries, production at scale
  - Requires: `elasticsearch` or `full` profile

> **Why Meilisearch by default?**
> - ✅ 10x less RAM (95 MB vs 996 MB)
> - ✅ Faster setup and initialization
> - ✅ Simpler configuration
> - ✅ Perfect for 95% of projects
> - Switch to Elasticsearch only if you need advanced features or handle millions of documents

### Development Tools
- **mailhog**: Email testing tool
- **adminer**: Database management UI
- **redis-commander**: Redis management UI
- **dozzle**: Real-time Docker logs viewer with beautiful UI

## Docker Compose Profiles

Control which services start with profiles:

```bash
# FrankenPHP Profiles (Recommended)
COMPOSE_PROFILES=symfony make up      # FrankenPHP + MySQL + Redis + Meilisearch + RabbitMQ
COMPOSE_PROFILES=laravel make up      # FrankenPHP + MySQL + Redis + Meilisearch + RabbitMQ
COMPOSE_PROFILES=frankenphp make up   # Just FrankenPHP with basic services

# Traditional Nginx Profiles
COMPOSE_PROFILES=php-fpm,nginx make up        # Nginx + PHP-FPM stack

# Development Profile (includes dev tools)
COMPOSE_PROFILES=development make up   # FrankenPHP + all dev tools (Adminer, Dozzle, etc.)

# Full Profile (all services)
COMPOSE_PROFILES=full make up         # Everything enabled

# Specific database profiles
COMPOSE_PROFILES=mysql make up        # Include MySQL
COMPOSE_PROFILES=postgres make up     # Include PostgreSQL
```

> **Note**: Profiles can be combined. Example: `COMPOSE_PROFILES=frankenphp,mysql,redis make up`

### Switching Between Meilisearch and Elasticsearch

**Default**: Meilisearch runs with `laravel`, `symfony`, and `full` profiles.

**To switch from Meilisearch to Elasticsearch**:

```bash
# Stop Meilisearch
docker-compose stop meilisearch

# Start Elasticsearch (requires profile)
COMPOSE_PROFILES=frankenphp,elasticsearch docker-compose up -d elasticsearch

# Or edit .env to make it permanent
# Change: COMPOSE_PROFILES=frankenphp
# To: COMPOSE_PROFILES=frankenphp,elasticsearch
# Then: docker-compose up -d
```

**To switch back to Meilisearch** (recommended):

```bash
# Stop Elasticsearch
docker-compose stop elasticsearch

# Start Meilisearch (already in profile)
docker-compose up -d meilisearch
```

**Resource Usage Comparison**:
- Meilisearch: ~95 MB RAM (10x lighter)
- Elasticsearch: ~996 MB RAM (better for large-scale)

> **Tip**: For most Laravel/Symfony projects, Meilisearch is more than enough and saves resources.

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make install` | First-time setup |
| `make up` | Start containers |
| `make down` | Stop containers |
| `make restart` | Restart containers |
| `make rebuild` | Rebuild containers |
| `make logs` | View logs |
| `make shell` | Enter workspace |
| `make php` | Enter PHP-FPM container |
| `make composer CMD="install"` | Run Composer |
| `make artisan CMD="migrate"` | Run Laravel Artisan |
| `make console CMD="cache:clear"` | Run Symfony Console |
| `make test` | Run tests |
| `make mysql` | Enter MySQL CLI |
| `make postgres` | Enter PostgreSQL CLI |
| `make redis` | Enter Redis CLI |
| `make php-switch VER=8.2` | Switch PHP version |
| `make clean` | Remove all containers |

## PHP Version Switching

Switch between PHP versions easily (supports 8.1, 8.2, 8.3, 8.4):

```bash
# Switch to PHP 8.4 (latest)
make php-switch VER=8.4

# Switch to PHP 8.3
make php-switch VER=8.3

# Switch to PHP 8.2
make php-switch VER=8.2

# Switch to PHP 8.1
make php-switch VER=8.1
```

## XDebug Configuration

XDebug 3 is pre-configured for VSCode and PHPStorm.

### VSCode Setup

Add to `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/your-project": "${workspaceFolder}"
            }
        }
    ]
}
```

### PHPStorm Setup

1. Go to **Settings → PHP → Servers**
2. Create new server:
   - Name: `laradock-lite`
   - Host: `localhost`
   - Port: `80`
   - Debugger: `Xdebug`
   - Path mappings: `/var/www/your-project` → your local path

## Laravel Configuration

### Environment Variables

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=default
DB_USERNAME=default
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_HOST=mailhog
MAIL_PORT=1025

QUEUE_CONNECTION=redis
```

### Queue Workers

```bash
# Start queue worker
make artisan CMD="queue:work"

# With Horizon
make artisan CMD="horizon"
```

## Symfony Configuration

### Database URL

```env
# MySQL
DATABASE_URL="mysql://default:secret@mysql:3306/default?serverVersion=8.0"

# PostgreSQL
DATABASE_URL="postgresql://default:secret@postgres:5432/default?serverVersion=16&charset=utf8"
```

### Mailer Configuration

```env
MAILER_DSN=smtp://mailhog:1025
```

### Messenger (Queue)

```yaml
# config/packages/messenger.yaml
framework:
    messenger:
        transports:
            async: 'redis://redis:6379/messages'
```

## Project Structure

```
laradock-lite/
├── docs/                  # Documentation
│   ├── CADDYFILE.md      # Caddyfile configuration guide
│   └── FRANKENPHP.md     # FrankenPHP guide and comparison
├── services/              # Docker service configurations
│   ├── frankenphp/       # FrankenPHP (modern PHP server)
│   │   └── config/       # Caddyfile and framework configs
│   ├── php/              # PHP 8.1, 8.2, 8.3 (for PHP-FPM)
│   ├── nginx/            # Nginx with Laravel/Symfony configs
│   ├── workspace/        # Development container
│   ├── mysql/            # MySQL configuration
│   ├── postgres/         # PostgreSQL configuration
│   ├── redis/            # Redis configuration
│   ├── rabbitmq/         # RabbitMQ configuration
│   ├── elasticsearch/    # Elasticsearch configuration
│   ├── meilisearch/      # Meilisearch configuration
│   └── mailhog/          # Mailhog configuration
├── projects/             # Your Laravel/Symfony projects
├── logs/                 # Log files
├── docker-compose.yml    # Main Docker Compose file
├── .env.example         # Environment template
├── Makefile             # Useful commands
└── README.md            # This file
```

## Customization

### FrankenPHP / Caddyfile Configuration

The Caddyfile system is highly flexible and supports environment variables. See [docs/CADDYFILE.md](docs/CADDYFILE.md) for:
- Modular framework configurations
- Custom domain and port settings
- Worker mode configuration
- Production optimization
- Troubleshooting guide

Quick example - change document root:

```bash
# .env
SERVER_ROOT=/var/www/my-project/web
```

### Adding Custom PHP Extensions

#### For FrankenPHP

Edit `services/frankenphp/Dockerfile`:

```dockerfile
RUN install-php-extensions your_extension
```

Rebuild:
```bash
docker-compose build frankenphp
```

#### For PHP-FPM

Edit `services/php/{version}/Dockerfile`:

```dockerfile
RUN docker-php-ext-install your_extension
```

Rebuild:
```bash
make rebuild SERVICE=php-fpm
```

### Custom Nginx Configuration

1. Edit `services/nginx/sites/your-site.conf`
2. Restart Nginx: `docker-compose restart nginx`

### Custom MySQL Configuration

Edit `services/mysql/my.cnf` and rebuild:

```bash
docker-compose build mysql
```

## FrankenPHP vs PHP-FPM + Nginx

Laradock Lite supports both modern (FrankenPHP) and traditional (PHP-FPM + Nginx) stacks.

### When to Use FrankenPHP (Recommended)

- ✅ New projects and greenfield development
- ✅ Need HTTP/2, HTTP/3, automatic HTTPS
- ✅ Want simpler deployment (single binary)
- ✅ Performance is critical (300%+ faster with worker mode)
- ✅ Building real-time applications (WebSockets, SSE)
- ✅ Using Laravel Octane or Symfony Runtime

### When to Use PHP-FPM + Nginx

- ⚠️ Migrating legacy applications with complex Nginx configs
- ⚠️ Team expertise is primarily with traditional stack
- ⚠️ Using Nginx-specific modules
- ⚠️ Running PHP <7.4 applications

### Performance Comparison

| Metric | PHP-FPM + Nginx | FrankenPHP (traditional) | FrankenPHP (worker) |
|--------|-----------------|--------------------------|---------------------|
| Req/sec | Baseline | +20-30% | +300-500% |
| Response time | Baseline | -15-20% | -70-80% |
| Memory | Higher | Medium | Lower |
| Configuration | 2 files | 1 file | 1 file |
| HTTP/3 Support | No | Yes | Yes |

> **Learn More**: See [docs/FRANKENPHP.md](docs/FRANKENPHP.md) for detailed comparison, benchmarks, and migration guide.

## Troubleshooting

### 🔴 FrankenPHP: Caddyfile Changes Not Applied

**Problem**: Modified `services/frankenphp/config/Caddyfile` but changes don't appear

**Cause**: Caddyfile is copied into Docker image at build time, not mounted as volume

**Solution**:
```bash
# REQUIRED after ANY Caddyfile modification
docker-compose build frankenphp
docker-compose up -d frankenphp
```

**Why**: The Dockerfile contains `COPY config/Caddyfile /etc/frankenphp/Caddyfile` at build stage. Just restarting the container won't reload the new configuration.

> **📝 Note**: The `./scripts/new-project.sh` script automatically rebuilds FrankenPHP for you.

### PrestaShop Blank Page

**Problem**: PrestaShop shows blank page after installation

**Solution**: Rebuild FrankenPHP after adding PrestaShop to Caddyfile
```bash
docker-compose build frankenphp
docker-compose up -d frankenphp
```

**Prevention**: Use `./scripts/new-project.sh prestashop my-shop` which handles everything automatically.

### Permission Issues

```bash
# Fix permissions in workspace
make shell
fix-perms
```

### Port Already in Use

Change ports in `.env`:

```env
NGINX_HOST_HTTP_PORT=8080
MYSQL_PORT=3307
```

### Rebuild Everything

```bash
make down
make rebuild
make up
```

### View Logs

#### Using Dozzle (Recommended)

Access the beautiful web UI: http://localhost:8888

- Real-time log streaming
- Search and filter
- Multiple container views
- No terminal needed

#### Using Docker Commands

```bash
# All services
make logs

# Specific service
make logs SERVICE=frankenphp
docker-compose logs -f nginx

# Last 100 lines
docker-compose logs --tail=100 frankenphp
```

## Performance Optimization

### macOS/Windows Performance

The configuration uses `:cached` flag for volume mounts to improve performance on macOS/Windows.

### Production Settings

For production, update `.env`:

```env
PHP_FPM_INSTALL_XDEBUG=false
APP_DEBUG=false
```

## 📚 Documentation

**→ [Index Complet de la Documentation](docs/INDEX.md)**

### 🚀 Démarrage Rapide

| Guide | Description | Temps |
|-------|-------------|-------|
| **[Quick Start](#quick-start)** | Installation et premier projet | 5 min |
| **[Pourquoi Lite ?](docs/WHY_LARADOCK_LITE.md)** | Comparaison détaillée avec Laradock | 15 min |
| **[Workspace](docs/guides/WORKSPACE_GUIDE.md)** | Menu interactif, navigation intelligente | 15 min |
| **[Créer un Projet](docs/guides/NEW_PROJECT_GUIDE.md)** | Scripts automation multi-OS | 20 min |

### 📖 Guides Pratiques

- **[Workspace Intelligent](docs/guides/WORKSPACE_GUIDE.md)** - Menu interactif, aliases, helpers
- **[Création de Projets](docs/guides/NEW_PROJECT_GUIDE.md)** - Scripts multi-OS (Linux/macOS/Windows/WSL)
- **[Configuration HTTPS](docs/guides/FRANKENPHP_HTTPS_SETUP.md)** - Switch HTTP/HTTPS automatique
- **[Multi-Projet](docs/guides/FRANKENPHP_MULTI_PROJECT.md)** - Architecture instance unique

### 📘 Références Techniques

- **[FrankenPHP](docs/reference/FRANKENPHP.md)** - Worker mode, performance, Laravel Octane
- **[Caddyfile](docs/reference/CADDYFILE.md)** - Configuration Caddy avancée

### 🛠️ Scripts & Automation

**[Documentation Scripts Complète](scripts/README.md)**

```bash
# Créer un projet (multi-OS)
sudo ./scripts/new-project.sh laravel my-app
sudo ./scripts/new-project.sh symfony my-api
sudo ./scripts/new-project.sh prestashop my-shop  # ✨ NEW: PrestaShop support

# Gérer /etc/hosts (Linux/macOS/Windows/WSL)
sudo ./scripts/hosts-manager.sh add myapp.localhost

# Switch HTTP/HTTPS
./scripts/frankenphp-https.sh enable
```

### 🎯 Par Cas d'Usage

- **Nouveau sur PHPModDock-Lite ?** → [Quick Start](#quick-start) + [Pourquoi Lite ?](docs/WHY_PHPMODDOCK.md)
- **Créer un projet Laravel ?** → [Guide Projets - Laravel](docs/guides/NEW_PROJECT_GUIDE.md#laravel)
- **Créer un projet Symfony ?** → [Guide Projets - Symfony](docs/guides/NEW_PROJECT_GUIDE.md#symfony)
- **Créer une boutique PrestaShop ?** → `./scripts/new-project.sh prestashop my-shop`
- **Gérer plusieurs projets ?** → [Guide Multi-Projet](docs/guides/FRANKENPHP_MULTI_PROJECT.md)
- **Optimiser performance ?** → [FrankenPHP - Worker Mode](docs/reference/FRANKENPHP.md)
- **Windows/WSL ?** → [Guide Projets - Multi-OS](docs/guides/NEW_PROJECT_GUIDE.md#gestion-multi-os-du-etchosts)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this in your projects.

## Acknowledgments

- Inspired by [Laradock](https://laradock.io/)
- Built for the Laravel and Symfony communities

## Support

For issues and questions:
- Open an issue on GitHub
- Check the troubleshooting section
- Review Docker Compose logs

---

**Made with ❤️ for Laravel and Symfony developers**
