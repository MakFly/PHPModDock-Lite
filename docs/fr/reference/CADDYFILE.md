# Caddyfile Configuration Guide

This guide explains how to configure FrankenPHP using the Caddyfile system in PHPModDock-Lite.

## Table of Contents

- [Overview](#overview)
- [Main Configuration](#main-configuration)
- [Environment Variables](#environment-variables)
- [Framework-Specific Configurations](#framework-specific-configurations)
  - [Laravel Configuration](#laravel-configuration)
  - [Symfony Configuration](#symfony-configuration)
- [Customization Examples](#customization-examples)
- [Troubleshooting](#troubleshooting)

## Overview

PHPModDock-Lite uses [FrankenPHP](https://frankenphp.dev/) with [Caddy](https://caddyserver.com/) as the web server. The configuration is split into:

- **Main Caddyfile**: `services/frankenphp/config/Caddyfile` - Base configuration
- **Framework configs**: `services/frankenphp/config/Caddyfile.d/*.caddyfile` - Optional framework-specific settings

This modular approach allows you to:
- Keep a clean base configuration
- Enable only the features you need
- Easily switch between Laravel and Symfony
- Customize without modifying the base Caddyfile

## Main Configuration

The main Caddyfile (`services/frankenphp/config/Caddyfile`) follows the official FrankenPHP format:

```caddyfile
{
	# Global options
	auto_https {$CADDY_AUTO_HTTPS:off}
	admin {$CADDY_ADMIN:off}

	frankenphp {
		num_threads {$FRANKENPHP_NUM_THREADS:4}
	}
}

:80 {
	# Server configuration
	root * {$SERVER_ROOT:/var/www/public}

	# PHP Server
	php_server {
		resolve_root_symlink
	}

	# Health check
	handle /health {
		respond "OK" 200
	}
}

# Import framework-specific configs
import Caddyfile.d/*.caddyfile
```

### Key Features:

- **HTTP on port 80**: Configured for local development (no HTTPS)
- **Environment variables**: All major settings are configurable via `.env`
- **Health check endpoint**: `/health` for monitoring
- **Security headers**: Pre-configured for production
- **Compression**: Automatic with zstd, brotli, and gzip
- **Modular imports**: Framework configs loaded from `Caddyfile.d/`

## Environment Variables

Configure FrankenPHP behavior through these `.env` variables:

### Server Configuration

```bash
# Server basics
SERVER_NAME=localhost                    # Server name (for logging)
SERVER_ROOT=/var/www/public             # Document root path

# Caddy settings
CADDY_AUTO_HTTPS=off                    # HTTPS mode: off, disable_redirects, ignore_loaded_certs
CADDY_ADMIN=off                         # Admin API: off, localhost:2019, :2019
LOG_LEVEL=INFO                          # Logging: DEBUG, INFO, WARN, ERROR

# FrankenPHP performance
FRANKENPHP_NUM_WORKERS=2                # Worker processes (production mode)
FRANKENPHP_NUM_THREADS=4                # Number of threads per worker
```

### Laravel-Specific Variables

```bash
# Vite dev server (for HMR - Hot Module Replacement)
VITE_HOST=host.docker.internal          # Vite server host
VITE_PORT=5173                          # Vite server port

# Laravel Reverb (WebSocket server)
REVERB_HOST=localhost                   # Reverb server host
REVERB_PORT=8085                        # Reverb server port
```

### Symfony-Specific Variables

```bash
# Mercure Hub (real-time updates)
MERCURE_HOST=mercure                    # Mercure server host
MERCURE_PORT=80                         # Mercure server port
```

## Framework-Specific Configurations

### Laravel Configuration

To enable Laravel-specific features:

```bash
cd services/frankenphp/config/Caddyfile.d
mv laravel.caddyfile.example laravel.caddyfile
```

This enables:

#### 1. Vite HMR (Hot Module Replacement)
Proxies Vite dev server for live reload during development:

```caddyfile
@vite {
	path /vite/* /@vite/* /@id/* /node_modules/*
}
reverse_proxy @vite {$VITE_HOST}:{$VITE_PORT}
```

**Usage**: Run `npm run dev` in your Laravel project, and HMR will work automatically.

#### 2. Laravel Reverb (WebSockets)
Proxies WebSocket connections for Laravel Broadcasting:

```caddyfile
@reverb {
	path /app/* /apps/*
}
reverse_proxy @reverb {$REVERB_HOST}:{$REVERB_PORT}
```

**Usage**: Configure Reverb in your Laravel `.env` and it will be accessible through the main domain.

#### 3. Static File Caching
Optimizes delivery of CSS, JS, images, and fonts:

```caddyfile
@static {
	file
	path *.css *.js *.ico *.gif *.jpg *.jpeg *.png *.svg *.woff *.woff2
}
header @static Cache-Control "public, max-age=31536000, immutable"
```

### Symfony Configuration

To enable Symfony-specific features:

```bash
cd services/frankenphp/config/Caddyfile.d
mv symfony.caddyfile.example symfony.caddyfile
```

This enables:

#### 1. Webpack Encore Support
Serves compiled assets from `/build/`:

```caddyfile
@webpack {
	path /build/*
}
file_server @webpack
```

#### 2. Symfony Profiler
Ensures the web debug toolbar and profiler work correctly:

```caddyfile
@profiler {
	path /_wdt/* /_profiler/*
}
php_server @profiler
```

#### 3. Mercure Hub (Optional)
For real-time updates with Symfony UX Turbo:

```caddyfile
@mercure {
	path /.well-known/mercure
}
reverse_proxy @mercure {$MERCURE_HOST}:{$MERCURE_PORT}
```

**Note**: Uncomment these lines if you're using Mercure.

#### 4. Security
Blocks access to dotfiles (except `.well-known/`):

```caddyfile
@dotfiles {
	path */.*
	not path */.well-known/*
}
respond @dotfiles 403
```

## Customization Examples

### Example 1: Custom Document Root

If your project uses a different public directory:

```bash
# .env
SERVER_ROOT=/var/www/web  # For Symfony projects using /web instead of /public
```

### Example 2: Enable HTTPS for Production

```bash
# .env
CADDY_AUTO_HTTPS=on
SERVER_NAME=example.com
```

### Example 3: Multiple Projects

Create additional Caddyfile configurations:

```caddyfile
# services/frankenphp/config/Caddyfile.d/my-project.caddyfile
:8080 {
	root * /var/www/my-other-project/public
	php_server
}
```

Then map the port in `docker-compose.yml`:

```yaml
services:
  frankenphp:
    ports:
      - "80:80"
      - "8080:8080"  # Add this
```

### Example 4: Custom PHP Directives

Use environment variables to pass custom directives:

```bash
# .env
PHP_SERVER_EXTRA_DIRECTIVES="\
  env[APP_ENV] APP_ENV\n\
  env[APP_SECRET] APP_SECRET\
"
```

### Example 5: Worker Mode for Production

Enable FrankenPHP worker mode for maximum performance:

```bash
# .env
FRANKENPHP_NUM_WORKERS=4
FRANKENPHP_NUM_THREADS=8
```

Then update your application to use the worker runtime (see [FRANKENPHP.md](FRANKENPHP.md)).

## Troubleshooting

### Issue: Changes to Caddyfile not applied

**Solution**: Rebuild the FrankenPHP container:

```bash
docker-compose build --no-cache frankenphp
docker-compose up -d frankenphp
```

### Issue: 404 errors for all requests

**Problem**: Incorrect `SERVER_ROOT` path.

**Solution**: Verify your project structure and update `.env`:

```bash
# Laravel projects
SERVER_ROOT=/var/www/public

# Symfony projects (older versions)
SERVER_ROOT=/var/www/web

# Symfony 4+ projects
SERVER_ROOT=/var/www/public
```

### Issue: Vite HMR not working in Laravel

**Checklist**:
1. Is `laravel.caddyfile.example` renamed to `laravel.caddyfile`?
2. Is `npm run dev` running in your project?
3. Is `VITE_HOST=host.docker.internal` set in `.env`?
4. Did you rebuild FrankenPHP after enabling the config?

### Issue: Symfony Profiler not showing

**Checklist**:
1. Is `symfony.caddyfile.example` renamed to `symfony.caddyfile`?
2. Is `APP_ENV=dev` in your Symfony `.env`?
3. Did you rebuild FrankenPHP after enabling the config?

### Issue: Connection refused on port 80

**Problem**: Port 80 might be in use by another service.

**Solution**: Change the port mapping in `docker-compose.yml`:

```yaml
services:
  frankenphp:
    ports:
      - "8080:80"  # Access via http://localhost:8080
```

### Issue: FrankenPHP not starting

**Debug steps**:

```bash
# Check logs
docker-compose logs frankenphp

# Test Caddyfile syntax
docker-compose exec frankenphp frankenphp validate --config /etc/frankenphp/Caddyfile

# Start in foreground to see errors
docker-compose up frankenphp
```

## Advanced Topics

### Custom Global Options

Add advanced Caddy options via environment variables:

```bash
# .env
CADDY_GLOBAL_OPTIONS="\
  grace_period 30s\n\
  shutdown_delay 10s\
"
```

### Custom Server Directives

Add custom directives to the server block:

```bash
# .env
CADDY_SERVER_EXTRA_DIRECTIVES="\
  header / X-Custom-Header \"MyValue\"\n\
  @api path /api/*\n\
  header @api Access-Control-Allow-Origin *\
"
```

### Debugging Caddy Configuration

View the final compiled configuration:

```bash
docker-compose exec frankenphp frankenphp adapt --config /etc/frankenphp/Caddyfile
```

This outputs the JSON configuration that Caddy actually uses.

## References

- [FrankenPHP Documentation](https://frankenphp.dev/docs/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddyfile Syntax](https://caddyserver.com/docs/caddyfile)
- [FrankenPHP Laravel Integration](https://frankenphp.dev/docs/laravel/)
- [FrankenPHP Symfony Integration](https://frankenphp.dev/docs/symfony/)
