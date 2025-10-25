# FrankenPHP Guide

This guide explains FrankenPHP, its benefits, and how to use it effectively in PHPModDock-Lite.

## Table of Contents

- [What is FrankenPHP?](#what-is-frankenphp)
- [FrankenPHP vs PHP-FPM + Nginx](#frankenphp-vs-php-fpm--nginx)
- [When to Use FrankenPHP](#when-to-use-frankenphp)
- [Performance: Worker Mode](#performance-worker-mode)
- [Laravel Integration](#laravel-integration)
- [Symfony Integration](#symfony-integration)
- [Configuration](#configuration)
- [Monitoring and Debugging](#monitoring-and-debugging)
- [Production Deployment](#production-deployment)

## What is FrankenPHP?

[FrankenPHP](https://frankenphp.dev/) is a modern PHP application server built on top of the [Caddy](https://caddyserver.com/) web server. It combines PHP execution with web serving in a single, efficient binary.

### Key Features

- **Modern HTTP**: HTTP/2, HTTP/3 (QUIC), and automatic HTTPS
- **Worker Mode**: Keep PHP applications in memory for dramatic performance gains
- **Zero Configuration**: Works out of the box with Laravel, Symfony, WordPress
- **Built-in Features**: Compression, security headers, graceful reloads
- **Real-time**: Native support for server-sent events (SSE) and WebSockets
- **Caddy Ecosystem**: Access to all Caddy modules and plugins

## FrankenPHP vs PHP-FPM + Nginx

### Traditional Stack (PHP-FPM + Nginx)

```
Request → Nginx → PHP-FPM → Bootstrap App → Execute → Shutdown → Response
          (web)   (process)  (every request)
```

**Characteristics**:
- Nginx handles HTTP, proxies PHP to PHP-FPM
- Each request bootstraps the entire application
- Two separate processes to configure and monitor
- Well-established, stable, widely documented
- Higher memory usage (separate processes)

### FrankenPHP Stack

```
Request → FrankenPHP → Execute (app already in memory) → Response
          (web + PHP)
```

**Characteristics**:
- Single process handles HTTP and PHP execution
- Worker mode keeps application in memory
- Simpler configuration (one Caddyfile)
- Modern HTTP protocols (HTTP/3, etc.)
- Lower memory footprint
- Better performance with worker mode

### Performance Comparison

| Metric | PHP-FPM + Nginx | FrankenPHP (traditional) | FrankenPHP (worker) |
|--------|----------------|-------------------------|---------------------|
| Requests/sec | Baseline | +20-30% | +300-500% |
| Response time | Baseline | -15-20% | -70-80% |
| Memory (idle) | ~200MB | ~150MB | ~180MB |
| Memory (load) | ~500MB | ~350MB | ~400MB |
| Bootstrap time | Every request | Every request | Once at startup |
| Configuration | 2 configs | 1 config | 1 config |

*Note: These are approximate values and vary by application.*

## When to Use FrankenPHP

### ✅ Use FrankenPHP When:

- Starting a new project
- Need modern HTTP protocols (HTTP/3, WebSockets)
- Want simpler deployment (single binary)
- Performance is important (especially with worker mode)
- Working with Laravel Octane or Symfony Runtime
- Building real-time applications (SSE, WebSockets)
- Want automatic HTTPS in production

### ⚠️ Consider PHP-FPM + Nginx When:

- Migrating legacy applications with specific Nginx configs
- Team is more familiar with traditional stack
- Using Nginx-specific modules (e.g., ModSecurity)
- Need battle-tested production setup
- Running very old PHP applications

### Switching Between Stacks

PHPModDock-Lite supports both! Switch using Docker Compose profiles:

```bash
# Use FrankenPHP (recommended)
COMPOSE_PROFILES=symfony docker-compose up -d

# Use PHP-FPM + Nginx (traditional)
COMPOSE_PROFILES=php-fpm,nginx docker-compose up -d
```

## Performance: Worker Mode

Worker mode is FrankenPHP's superpower: it keeps your PHP application in memory between requests, eliminating bootstrap overhead.

### How Worker Mode Works

```
Traditional Mode:
Request → Load PHP → Bootstrap Framework → Load Config → Execute → Shutdown

Worker Mode:
Startup → Bootstrap Framework → Load Config → Listen
Request → Execute (framework already loaded) → Response
Request → Execute (framework already loaded) → Response
...
```

### Performance Gains

Real-world benchmarks:

```
Traditional PHP-FPM:
- Requests per second: 1,200
- Average response time: 45ms
- Peak memory: 512MB

FrankenPHP Worker Mode:
- Requests per second: 6,500 (+440%)
- Average response time: 8ms (-82%)
- Peak memory: 420MB (-18%)
```

### Considerations

Worker mode requires application support:
- **Laravel**: Use Laravel Octane (see below)
- **Symfony**: Use Symfony Runtime (see below)
- **Custom apps**: Implement worker-compatible code

**Important**: Not all code is worker-safe. Stateful global variables, singletons, and static properties must be handled carefully.

## Laravel Integration

### Standard Mode (No Configuration Needed)

FrankenPHP works with Laravel out of the box:

```bash
# Create Laravel project
cd projects
composer create-project laravel/laravel my-app
cd my-app

# Configure .env
cp .env.example .env
php artisan key:generate

# Update host .env
SERVER_ROOT=/var/www/my-app/public
```

Restart FrankenPHP:
```bash
docker-compose restart frankenphp
```

### Worker Mode with Laravel Octane

For maximum performance, use Laravel Octane with FrankenPHP:

#### 1. Install Octane

```bash
docker-compose exec workspace bash
cd my-app

composer require laravel/octane
php artisan octane:install --server=frankenphp
```

#### 2. Update Dockerfile

Add Octane support to `services/frankenphp/Dockerfile`:

```dockerfile
# After the Composer installation
RUN if [ -f /var/www/composer.json ] && grep -q "laravel/octane" /var/www/composer.json; then \
    composer require --working-dir=/var/www laravel/octane; \
fi
```

#### 3. Update Caddyfile

Replace the standard `php_server` with Octane worker:

```caddyfile
# services/frankenphp/config/Caddyfile.d/laravel-octane.caddyfile
php_server {
    worker {
        file /var/www/public/index.php
        num {$FRANKENPHP_NUM_WORKERS:2}
    }
}
```

#### 4. Configure Environment

```bash
# .env
FRANKENPHP_NUM_WORKERS=4       # Number of workers (2 × CPU cores)
FRANKENPHP_NUM_THREADS=8       # Threads per worker
```

#### 5. Rebuild and Restart

```bash
docker-compose build frankenphp
docker-compose up -d frankenphp
```

### Laravel Vite HMR (Hot Module Replacement)

Enable Vite dev server proxying for live reload:

```bash
cd services/frankenphp/config/Caddyfile.d
mv laravel.caddyfile.example laravel.caddyfile
docker-compose restart frankenphp
```

In your Laravel project, run:
```bash
npm install
npm run dev
```

Changes to JS/CSS will now hot-reload automatically!

### Laravel Reverb (WebSockets)

Laravel Reverb WebSocket server works seamlessly:

```bash
# Install Reverb
composer require laravel/reverb

# Configure
php artisan reverb:install
```

The `laravel.caddyfile` config automatically proxies WebSocket connections.

## Symfony Integration

### Standard Mode (No Configuration Needed)

FrankenPHP works with Symfony out of the box:

```bash
# Create Symfony project
cd projects
symfony new my-app --webapp
cd my-app

# Update host .env
SERVER_ROOT=/var/www/my-app/public
```

Restart FrankenPHP:
```bash
docker-compose restart frankenphp
```

### Worker Mode with Symfony Runtime

For maximum performance, use Symfony Runtime with FrankenPHP:

#### 1. Install Runtime Component

```bash
docker-compose exec workspace bash
cd my-app

composer require runtime/frankenphp-symfony
```

#### 2. Update public/index.php

```php
<?php

use App\Kernel;

require_once dirname(__DIR__).'/vendor/autoload_runtime.php';

return function (array $context) {
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};
```

This is the default for Symfony 6+. For Symfony 5.4, replace the traditional bootstrap.

#### 3. Update Caddyfile

Replace the standard `php_server` with worker mode:

```caddyfile
# services/frankenphp/config/Caddyfile.d/symfony-worker.caddyfile
php_server {
    worker {
        file /var/www/public/index.php
        num {$FRANKENPHP_NUM_WORKERS:2}
        env APP_RUNTIME Runtime\FrankenPhpSymfony\Runtime
    }
}
```

#### 4. Configure Environment

```bash
# .env
FRANKENPHP_NUM_WORKERS=4
FRANKENPHP_NUM_THREADS=8
```

#### 5. Rebuild and Restart

```bash
docker-compose build frankenphp
docker-compose up -d frankenphp
```

### Symfony Profiler

Enable Symfony Web Debug Toolbar and Profiler:

```bash
cd services/frankenphp/config/Caddyfile.d
mv symfony.caddyfile.example symfony.caddyfile
docker-compose restart frankenphp
```

Ensure `APP_ENV=dev` in your Symfony `.env` file.

### Symfony Webpack Encore

The Symfony Caddyfile config automatically serves assets from `/build/`:

```bash
# Install Encore
composer require symfony/webpack-encore-bundle

# Build assets
npm install
npm run dev  # Development
npm run build  # Production
```

### API Platform

FrankenPHP is excellent for API Platform projects:

```bash
composer require api-platform/core

# Enable worker mode for maximum API performance
# Follow "Worker Mode with Symfony Runtime" steps above
```

With worker mode, API Platform can serve 5,000+ req/sec on modest hardware.

## Configuration

### Environment Variables

Configure FrankenPHP behavior via `.env`:

```bash
# Worker Configuration
FRANKENPHP_NUM_WORKERS=2        # Number of worker processes
FRANKENPHP_NUM_THREADS=4        # Threads per worker

# Server Configuration
SERVER_NAME=localhost            # Domain name
SERVER_ROOT=/var/www/public     # Document root
CADDY_AUTO_HTTPS=off            # HTTPS: off, on, disable_redirects

# Logging
LOG_LEVEL=INFO                  # DEBUG, INFO, WARN, ERROR
```

### Optimal Worker Settings

**Development**:
```bash
FRANKENPHP_NUM_WORKERS=2        # Low memory usage
FRANKENPHP_NUM_THREADS=2        # Easy debugging
```

**Production**:
```bash
FRANKENPHP_NUM_WORKERS=8        # 2 × CPU cores
FRANKENPHP_NUM_THREADS=16       # 2 × workers
```

**Formula**: `workers = 2 × CPU_CORES`, `threads = 2 × workers`

### Memory Sizing

Each worker holds a complete application instance:

```
Memory = (Worker Memory × Num Workers) + Overhead

Example:
- Laravel app: ~80MB per worker
- 4 workers: 80 × 4 = 320MB
- Overhead: ~100MB
- Total: ~420MB
```

Size your container accordingly:

```yaml
# docker-compose.yml
services:
  frankenphp:
    deploy:
      resources:
        limits:
          memory: 512M  # For 4 workers
```

## Monitoring and Debugging

### Health Check

FrankenPHP includes a built-in health endpoint:

```bash
curl http://localhost/health
# OK
```

### Viewing Logs

```bash
# Real-time logs
docker-compose logs -f frankenphp

# Last 100 lines
docker-compose logs --tail=100 frankenphp
```

### Worker Status

Monitor worker processes:

```bash
docker-compose exec frankenphp ps aux
```

You should see one main FrankenPHP process and multiple PHP workers.

### Performance Metrics

FrankenPHP exposes Prometheus metrics:

```bash
# Enable metrics endpoint
# .env
CADDY_ADMIN=:2019

# Access metrics
curl http://localhost:2019/metrics
```

### XDebug Support

XDebug works with FrankenPHP:

```bash
# .env
PHP_FPM_INSTALL_XDEBUG=true
XDEBUG_MODE=debug
XDEBUG_CLIENT_HOST=host.docker.internal
XDEBUG_CLIENT_PORT=9003
```

Configure your IDE:
- **Server name**: `laradock-lite`
- **Host**: `host.docker.internal`
- **Port**: `9003`

### Debugging Worker Issues

If workers crash or behave unexpectedly:

```bash
# Disable worker mode temporarily
# Comment out worker configuration in Caddyfile

# Check for stateful code issues
# Look for global variables, static properties, singletons

# Enable debug logging
LOG_LEVEL=DEBUG

# Restart and monitor
docker-compose restart frankenphp
docker-compose logs -f frankenphp
```

## Production Deployment

### Checklist

- [ ] Enable worker mode for performance
- [ ] Configure appropriate worker/thread counts
- [ ] Enable HTTPS: `CADDY_AUTO_HTTPS=on`
- [ ] Set production log level: `LOG_LEVEL=WARN`
- [ ] Configure error handling (disable debug mode)
- [ ] Set up health check monitoring
- [ ] Configure resource limits (memory, CPU)
- [ ] Enable compression (enabled by default)
- [ ] Configure security headers (enabled by default)
- [ ] Test worker mode thoroughly (state management)

### Production Environment Variables

```bash
# Production .env
FRANKENPHP_NUM_WORKERS=8
FRANKENPHP_NUM_THREADS=16
SERVER_NAME=example.com
CADDY_AUTO_HTTPS=on
LOG_LEVEL=WARN
```

### HTTPS with Let's Encrypt

FrankenPHP (via Caddy) handles HTTPS automatically:

```bash
# .env
SERVER_NAME=example.com
CADDY_AUTO_HTTPS=on

# docker-compose.yml
services:
  frankenphp:
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"  # HTTP/3
    volumes:
      - caddy-data:/data/caddy  # Persist certificates
```

Add volume:
```yaml
volumes:
  caddy-data:
    driver: local
```

### Graceful Reloads

FrankenPHP supports zero-downtime reloads:

```bash
# Reload configuration
docker-compose exec frankenphp frankenphp reload --config /etc/frankenphp/Caddyfile

# Graceful restart
docker-compose exec frankenphp kill -USR1 1
```

### Horizontal Scaling

For high-traffic applications:

```yaml
# docker-compose.yml
services:
  frankenphp:
    deploy:
      replicas: 3  # Run 3 instances
```

Add a load balancer (Traefik, HAProxy, or cloud load balancer) in front.

## Best Practices

### Worker Mode Development

1. **Avoid Global State**: Use dependency injection, not global variables
2. **Reset State**: Clear caches, reset counters between requests
3. **Watch for Leaks**: Monitor memory usage over time
4. **Test Thoroughly**: Worker mode can expose hidden state issues
5. **Use Octane/Runtime**: Let the framework handle worker concerns

### Configuration Management

1. **Environment Variables**: Use `.env` for all configuration
2. **Modular Caddyfiles**: Keep framework configs in `Caddyfile.d/`
3. **Version Control**: Commit `.example` files, ignore actual configs
4. **Documentation**: Document custom configurations

### Performance Tuning

1. **Benchmark**: Measure before optimizing
2. **Scale Gradually**: Start with 2 workers, increase based on load
3. **Monitor**: Watch memory, CPU, response times
4. **Cache Aggressively**: Use Redis, OPcache, application caching
5. **Profile**: Use XDebug, Blackfire, or Tideways

## Troubleshooting

### Workers Keep Crashing

**Symptoms**: FrankenPHP restarts repeatedly, 500 errors

**Causes**:
- Memory leaks in worker mode
- Uncaught exceptions in worker initialization
- Incompatible code (stateful globals)

**Solutions**:
1. Disable worker mode temporarily
2. Check logs: `docker-compose logs frankenphp`
3. Review application for worker-incompatible code
4. Increase memory limit if needed

### Performance Not Improved

**Check**:
- Is worker mode actually enabled?
- Are workers starting? Check `ps aux` in container
- Is opcache enabled? Check `php -i | grep opcache`
- Are you benchmarking correctly? (Use `wrk` or `ab`)

### Application State Issues

**Symptoms**: Data from one request appears in another, random bugs

**Cause**: Global state in worker mode

**Solution**:
1. Identify stateful code (globals, static properties)
2. Refactor to use dependency injection
3. Use Octane/Runtime state management features
4. Reset state between requests in worker

## Resources

- [FrankenPHP Official Documentation](https://frankenphp.dev/docs/)
- [FrankenPHP GitHub Repository](https://github.com/dunglas/frankenphp)
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Laravel Octane Documentation](https://laravel.com/docs/octane)
- [Symfony Runtime Documentation](https://symfony.com/doc/current/components/runtime.html)
- [FrankenPHP Laravel Guide](https://frankenphp.dev/docs/laravel/)
- [FrankenPHP Symfony Guide](https://frankenphp.dev/docs/symfony/)
