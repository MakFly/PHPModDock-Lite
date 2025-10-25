# FrankenPHP Service - Configuration Guide

## Overview

This service uses FrankenPHP, a modern PHP application server built on Caddy, providing superior performance compared to traditional PHP-FPM setups.

**Official Documentation**: https://frankenphp.dev/fr/docs/config/

## Configuration Approach

### Simplified Architecture

The configuration has been simplified to follow FrankenPHP's official recommendations:

- **Single Caddyfile**: One configuration file, no complex imports
- **Environment Variables**: Dynamic configuration via docker-compose
- **No Custom Overrides**: Minimal, maintainable setup

### Why This Approach?

The previous multi-file configuration (`Caddyfile.d/`) created conflicts:
- Ambiguous server routing between main and imported configs
- Mixed static/dynamic configuration approaches
- Difficult debugging and maintenance
- Non-standard FrankenPHP setup

## Environment Variables

Configure your FrankenPHP instance via `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | `localhost` | Server hostname(s) |
| `SERVER_ROOT` | `/var/www/public` | Document root directory |
| `FRANKENPHP_NUM_WORKERS` | - | Number of PHP workers |
| `FRANKENPHP_NUM_THREADS` | - | Number of threads per worker |
| `CADDY_AUTO_HTTPS` | `off` | Enable/disable auto HTTPS |
| `LOG_LEVEL` | `INFO` | Logging level |

## Multi-Project Setup (CURRENT CONFIGURATION)

This setup runs **one FrankenPHP instance** serving both Laravel and Symfony projects simultaneously via different ports.

### Architecture

- **frankenphp**: Single instance serving multiple projects
  - Laravel on port: 8080
  - Symfony on port: 8081
  - HTTPS on port: 8443
  - Container: `laradock_frankenphp`

### Access URLs

- **Laravel**: http://localhost:8080
- **Symfony**: http://localhost:8081

### Starting/Stopping

```bash
# Start FrankenPHP (serves both projects)
docker-compose up -d frankenphp

# View logs
docker logs -f laradock_frankenphp

# Stop
docker-compose down
```

### Configuration

The single instance is configured via the Caddyfile with multiple server blocks:

**`services/frankenphp/config/Caddyfile`**:
```caddyfile
# Laravel Application - Port 8080
:8080 {
    root * /var/www/laravel-app/public
    encode zstd br gzip
    log { output stdout; format console; level INFO }
    php_server
}

# Symfony Application - Port 8081
:8081 {
    root * /var/www/symfony-api/public
    encode zstd br gzip
    log { output stdout; format console; level INFO }
    php_server
}
```

### Why Single Instance?

✅ **Advantages**:
- Less memory usage (1 container vs 2)
- Simpler to manage and maintain
- Single point of monitoring
- Shared PHP opcache across projects
- Follows FrankenPHP official patterns

❌ **Disadvantages**:
- Projects share same PHP process pool
- Can't restart one project without affecting the other
- Port mapping slightly more complex

### Adding Another Project

1. Add a new server block in `services/frankenphp/config/Caddyfile`:
   ```caddyfile
   :8082 {
       root * /var/www/myapp/public
       encode zstd br gzip
       log { output stdout; format console; level INFO }
       php_server
   }
   ```

2. Add port mapping in `docker-compose.yml`:
   ```yaml
   ports:
     - "${FRANKENPHP_HTTP_PORT_MYAPP}:8082"
   ```

3. Add port variable to `.env`:
   ```bash
   FRANKENPHP_HTTP_PORT_MYAPP=8082
   ```

## Worker Mode (Performance)

For production performance, enable worker mode in your Caddyfile:

1. Uncomment the worker section in `config/Caddyfile`
2. Create a worker script for your framework:
   - Laravel: https://laravel.com/docs/octane#frankenphp
   - Symfony: https://symfony.com/doc/current/deployment/frankenphp.html

## PHP Configuration

PHP settings are configured via:
- `config/php.ini` - Copied to `/usr/local/etc/php/conf.d/99-custom.ini`

## Debugging

Enable debug logging:

```yaml
frankenphp:
  environment:
    - LOG_LEVEL=DEBUG
```

Or uncomment the log section in `config/Caddyfile`.

## Build Arguments

Available in `docker-compose.yml`:

| Argument | Default | Description |
|----------|---------|-------------|
| `PHP_VERSION` | `8.3` | PHP version to install |
| `INSTALL_REDIS` | `true` | Install Redis extension |
| `INSTALL_XDEBUG` | `false` | Install Xdebug extension |
| `INSTALL_NODE` | `false` | Install Node.js |
| `INSTALL_SYMFONY_CLI` | `false` | Install Symfony CLI |

## Backup Configuration

Old configuration files are backed up in:
```
services/frankenphp/config/backup_old_config/
```

This includes:
- Previous Caddyfile with imports
- Caddyfile.d/ directory with multi-project configs

## Common Issues

### Port Conflicts

If port 80 is already in use:

```yaml
ports:
  - "8080:80"  # Change host port
```

### Permission Errors

Ensure PUID/PGID match your host user:

```yaml
args:
  - PUID=1000  # Run: id -u
  - PGID=1000  # Run: id -g
```

### Application Not Loading

1. Verify `SERVER_ROOT` points to correct directory
2. Check application has `index.php` in public directory
3. Review logs: `docker logs laradock_frankenphp`

## Resources

- [FrankenPHP Official Docs](https://frankenphp.dev/)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Laravel Octane + FrankenPHP](https://laravel.com/docs/octane#frankenphp)
- [Symfony + FrankenPHP](https://symfony.com/doc/current/deployment/frankenphp.html)
