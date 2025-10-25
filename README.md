# 🚀 PHPModDock-Lite

**Modern Docker environment for Laravel, Symfony & PrestaShop** - Simple, Fast, Powerful.

> Modern alternative to Laradock: **3-4x faster**, **2-minute setup**, **2025 stack**.

[![PHP 8.4](https://img.shields.io/badge/PHP-8.1%20|%208.2%20|%208.3%20|%208.4-777BB4?style=flat-square&logo=php)](https://www.php.net/)
[![FrankenPHP](https://img.shields.io/badge/FrankenPHP-Latest-00ADD8?style=flat-square)](https://frankenphp.dev/)
[![Laravel](https://img.shields.io/badge/Laravel-11%20|%2012-FF2D20?style=flat-square&logo=laravel)](https://laravel.com/)
[![Symfony](https://img.shields.io/badge/Symfony-6%20|%207-000000?style=flat-square&logo=symfony)](https://symfony.com/)
[![PrestaShop](https://img.shields.io/badge/PrestaShop-8.x-DF0067?style=flat-square&logo=prestashop)](https://www.prestashop.com/)

> 🇫🇷 **French version**: [README.fr.md](README.fr.md)

---

## ✨ Why PHPModDock-Lite?

| Laradock (Original) | PHPModDock-Lite | Advantage |
|---------------------|-----------------|-----------|
| Setup 15-30 min | **Setup 2 min** | ⚡ **7x faster** |
| 150 req/s | **600 req/s** | 🚀 **4x performance** |
| 80+ services | **15 essential services** | 🎯 **Focused** |
| Manual config | **Automation scripts** | 🤖 **Intelligent** |
| 2016 tech | **2025 stack** | 🆕 **Modern** |

**→ [Read full comparison](docs/en/WHY_PHPMODDOCK.md)**

---

## 🎯 Key Features

### Exceptional Performance ⚡

- **FrankenPHP**: Ultra-fast Go server with native worker mode
- **HTTP/3 & HTTP/2**: Modern protocols enabled by default
- **Brotli & Gzip**: Automatic compression
- **300%+ Performance**: vs traditional Nginx+PHP-FPM

### Developer Experience 🎨

- **Smart Workspace**: Interactive menu, contextual aliases
- **Auto-Creation**: 1 command = ready project (Laravel/Symfony/PrestaShop)
- **Multi-Project**: Single instance serving multiple apps
- **Multi-OS**: Linux, macOS, Windows (Git Bash), native WSL

### Modern Stack 🆕

- **PHP**: 8.1, 8.2, 8.3, 8.4
- **Node.js**: 18, 20, 22
- **Databases**: MySQL 8, PostgreSQL 16
- **Cache**: Redis, Meilisearch
- **Queue**: RabbitMQ
- **Dev Tools**: Mailhog, Adminer, Dozzle

### Automation 🤖

- ✅ **new-project.sh** - Automatic project creation
- ✅ **hosts-manager.sh** - Multi-OS /etc/hosts management
- ✅ **frankenphp-https.sh** - HTTP/HTTPS switching
- ✅ **Workspace menu** - Intelligent navigation

## Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/phpmoddock-lite.git
cd phpmoddock-lite

# Run quick start script (recommended)
./quick-start.sh

# OR manual setup
cp .env.example .env
nano .env  # Configure your settings
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
> See [docs/en/reference/FRANKENPHP.md](docs/en/reference/FRANKENPHP.md) for details.

### 3. Create Your Project

```bash
# Enter workspace container
make workspace

# Create new project using scripts (recommended)
./scripts/new-project.sh laravel my-app
./scripts/new-project.sh symfony my-api
./scripts/new-project.sh prestashop my-shop  # NEW: PrestaShop support

# OR manually inside workspace
cd /var/www
composer create-project laravel/laravel my-app
# OR
symfony new my-api
```

### 4. Access Your Application

- **Application**: http://localhost
- **Adminer** (Database UI): http://localhost:8081
- **Mailhog** (Email Testing): http://localhost:8025
- **Redis Commander**: http://localhost:8082
- **Dozzle** (Docker Logs Viewer): http://localhost:8888
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Meilisearch**: http://localhost:7700 (if enabled)

> **🔒 Security Note**: All ports are bound to `127.0.0.1` (localhost only) for security on public WiFi.
> See [IMPORTANT_NOTES.md](IMPORTANT_NOTES.md#-security-for-nomadic-developers) for details.

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
- **elasticsearch** (8.11): Full-text search engine
- **meilisearch**: Modern, typo-tolerant search engine

### Development Tools
- **mailhog**: Email testing (catches all emails sent by your app)
- **adminer**: Database management UI (supports MySQL & PostgreSQL)
- **redis-commander**: Redis management UI
- **dozzle**: Real-time Docker logs viewer with web UI

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

## 🛠️ Scripts & Automation

**[Complete Scripts Documentation](scripts/README.md)**

```bash
# Create projects (multi-OS)
sudo ./scripts/new-project.sh laravel my-app
sudo ./scripts/new-project.sh symfony my-api
sudo ./scripts/new-project.sh prestashop my-shop  # ✨ NEW: PrestaShop support

# Manage /etc/hosts (Linux/macOS/Windows/WSL)
sudo ./scripts/hosts-manager.sh add myapp.localhost

# Switch HTTP/HTTPS
./scripts/frankenphp-https.sh enable
```

## 📚 Documentation

### 🚀 Getting Started

| Guide | Description | Time |
|-------|-------------|------|
| **[Quick Start](#quick-start)** | Install and run in minutes | 5 min |
| **[Create Project](docs/en/guides/NEW_PROJECT_GUIDE.md)** | Multi-OS automation scripts | 20 min |

### 📖 Usage Guides

- **[Project Creation](docs/en/guides/NEW_PROJECT_GUIDE.md)** - Multi-OS scripts (Linux/macOS/Windows/WSL)
- **[Multi-Project](docs/en/guides/FRANKENPHP_MULTI_PROJECT.md)** - Single instance, multiple apps
- **[Workspace](docs/en/guides/WORKSPACE_GUIDE.md)** - Intelligent workspace with contextual aliases

### 🔧 Technical Reference

- **[FrankenPHP](docs/en/reference/FRANKENPHP.md)** - Worker mode, performance, Laravel Octane
- **[Caddyfile](docs/en/reference/CADDYFILE.md)** - Advanced Caddy configuration

### 🎯 By Use Case

- **New to PHPModDock-Lite?** → [Quick Start](#quick-start) + [Why Lite?](docs/en/WHY_PHPMODDOCK.md)
- **Create Laravel project?** → [Project Guide - Laravel](docs/en/guides/NEW_PROJECT_GUIDE.md#laravel)
- **Create Symfony project?** → [Project Guide - Symfony](docs/en/guides/NEW_PROJECT_GUIDE.md#symfony)
- **Create PrestaShop store?** → `./scripts/new-project.sh prestashop my-shop`
- **Manage multiple projects?** → [Multi-Project Guide](docs/en/guides/FRANKENPHP_MULTI_PROJECT.md)
- **Optimize performance?** → [FrankenPHP - Worker Mode](docs/en/reference/FRANKENPHP.md)
- **Windows/WSL?** → [Project Guide - Multi-OS](docs/en/guides/NEW_PROJECT_GUIDE.md#multi-os-etchosts-management)

## 🔒 Security

**Important for nomadic developers** (working from cafés, coworking spaces, public WiFi):

All service ports are bound to `127.0.0.1` (localhost only) by default. This means:
- ✅ Services accessible ONLY from your machine
- ✅ NOT exposed to public WiFi networks
- ✅ Safe for development on untrusted networks

**Default passwords** in `.env.example` are prefixed with `CHANGE_ME_` - always change them!

See [IMPORTANT_NOTES.md - Security Section](IMPORTANT_NOTES.md#-security-for-nomadic-developers) for complete security guide.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is open-sourced software licensed under the [MIT license](LICENSE).

## Credits

- Built for the Laravel, Symfony, and PrestaShop communities
- Inspired by Laradock
- Powered by FrankenPHP, Docker, and amazing open-source tools

---

**Made with ❤️ for PHP developers**

**Star ⭐ this repo if you find it useful!**
