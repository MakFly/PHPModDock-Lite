# Changelog

All notable changes to PHPModDock-Lite will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-26

### Added
- Initial release of PHPModDock-Lite
- Multi-PHP version support (8.1, 8.2, 8.3)
- Multi-framework support (Laravel & Symfony)
- Docker Compose profiles for flexible service management
- Core services: PHP-FPM, Nginx, Workspace
- Database services: MySQL 8.0, PostgreSQL 16
- Cache & Queue: Redis 7, RabbitMQ 3
- Search engines: Elasticsearch 8.11, Meilisearch
- Development tools: Mailhog, Adminer, Redis Commander
- XDebug 3 configuration for VSCode and PHPStorm
- Comprehensive Makefile with useful commands
- Quick start script for automated setup
- Full documentation in README.md
- Example configurations for Laravel and Symfony
- Optimized PHP, Nginx, MySQL, and Redis configurations
- MIT License

### Features
- Profile-based service activation (minimal, full, laravel, symfony, development)
- Easy PHP version switching
- Pre-configured XDebug for debugging
- Performance optimizations for macOS/Windows
- Health checks for all major services
- Workspace container with Composer, Node.js, Symfony CLI, Git
- Custom shell aliases for Laravel and Symfony commands
- Production-ready configurations

### Documentation
- Complete README with quick start guide
- Troubleshooting section
- Laravel and Symfony configuration examples
- XDebug setup instructions
- Contributing guidelines
- MIT License

### Added (v0.1.0 features)
- **PrestaShop Support**: Full support for PrestaShop e-commerce platform
  - Auto-detection of PrestaShop projects
  - Automated project creation via `new-project.sh`
  - Caddyfile configuration for PrestaShop
- **FrankenPHP Modern Stack**: Migration from Nginx to FrankenPHP as primary web server
  - 3-4x performance improvement over traditional Nginx+PHP-FPM
  - HTTP/2 and HTTP/3 support out of the box
  - Worker mode for Laravel/Symfony applications
- **Dynamic Project Detection**: Auto-discovery of projects in `/projects` directory
  - REST API endpoint `/api/projects.php` for project listing
  - Framework auto-detection (Laravel, Symfony, PrestaShop, WordPress)
  - Real-time project list with "Refresh" button (no page reload needed)
- **Enhanced Quick Start Script**:
  - Two modes: Fresh installation & Git clone setup
  - Auto-detection of existing projects
  - Framework detection for cloned projects
  - Docker daemon verification
  - Multi-OS support (Linux, macOS, Windows/WSL)
- **Service Health Monitoring**: Real-time service status indicators on welcome page
  - Visual health checks for Adminer, Redis Commander, Mailhog, etc.
  - Auto-refresh every 30 seconds
  - Color-coded status (green=running, red=down)

### Changed
- **Rebranding**: Laradock-Lite → PHPModDock-Lite
- **Default Web Server**: FrankenPHP instead of Nginx (Nginx still available)
- **Project Structure**: HTML files now hot-reloadable (mounted as volumes)
- **Port Configuration**: Fixed Adminer (8081) and Redis Commander (8082) conflict
- **Container Naming**: Standardized to `phpmoddock_*` prefix

### Fixed
- PrestaShop blank page issue (Caddyfile rebuild requirement documented)
- Port conflicts between Adminer and Redis Commander
- FrankenPHP Caddyfile not being updated without rebuild
- macOS compatibility issues in quick-start.sh (sed differences)

### Documentation
- Added PrestaShop installation guide
- Added FrankenPHP rebuild instructions
- Updated quick-start.sh with both installation modes
- Enhanced README with dynamic project detection

## [Unreleased]

### Planned
- Add support for PHP 8.4
- Add WordPress automated setup
- Add Mercure hub for Symfony
- Add support for Laravel Octane
- Add Blackfire profiler
- Add more database options (MariaDB, MongoDB)
- Add CI/CD examples
- Docker Swarm configurations
- Kubernetes deployment examples
