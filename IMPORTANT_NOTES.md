# ⚠️ IMPORTANT NOTES - READ BEFORE USE

**Last updated**: 2025-10-26
**Version**: 0.1.0

> 🇫🇷 **French version**: [IMPORTANT_NOTES.fr.md](IMPORTANT_NOTES.fr.md)

---

## 🔴 CRITICAL POINTS TO KNOW

### 1. **FrankenPHP: REBUILD REQUIRED After Caddyfile Modification**

The `services/frankenphp/config/Caddyfile` file is **copied into the Docker image at build time**, not mounted as a volume.

**❌ COMMON MISTAKE:**
```bash
# Edit Caddyfile
nano services/frankenphp/config/Caddyfile

# Restart FrankenPHP
docker-compose restart frankenphp  # ❌ CHANGES ARE NOT APPLIED!
```

**✅ CORRECT PROCEDURE:**
```bash
# 1. Edit the Caddyfile
nano services/frankenphp/config/Caddyfile

# 2. Rebuild FrankenPHP image
docker-compose build frankenphp

# 3. Restart the container
docker-compose up -d frankenphp
```

**Why?** The Dockerfile contains:
```dockerfile
COPY config/Caddyfile /etc/frankenphp/Caddyfile  # Line 145
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]  # Line 154
```

---

### 2. **Automatic Project Detection**

Projects in `./projects/` are **automatically detected** and displayed on the welcome page.

**How it works:**
1. The `/api/projects.php` API scans `/var/www` (mounted from `./projects`)
2. Auto-detects framework (Laravel, Symfony, PrestaShop, WordPress)
3. Displays projects with appropriate icons and colors

**To refresh the list WITHOUT reloading the page:**
- Click the **"Refresh"** button at the top right of the "Your Projects" section

**Detected frameworks:**
- **Laravel**: `artisan` + `bootstrap/app.php`
- **Symfony**: `symfony.lock` + `bin/console`
- **PrestaShop**: `classes/PrestaShopAutoload.php` + `modules`
- **WordPress**: `wp-config.php` + `wp-content`

---

### 3. **PrestaShop Project Creation**

PrestaShop is now supported! Usage:

```bash
./scripts/new-project.sh prestashop my-shop
```

**What the script does:**
1. Downloads PrestaShop 8.2.0 from GitHub
2. Extracts files (double extraction needed: ZIP in ZIP)
3. Configures permissions (777 on specific folders)
4. Adds configuration to Caddyfile
5. Adds entry to `/etc/hosts`
6. **Automatically rebuilds FrankenPHP**

**Access:** `http://my-shop.localhost`

**Database configuration:**
- Server: `mysql`
- Database: `default` (or create one via Adminer)
- User: `default`
- Password: `secret`

---

### 4. **HTML Files Hot-Reload**

HTML files are now **mounted read-only** to allow hot modifications:

```yaml
# docker-compose.yml
frankenphp:
  volumes:
    - ./services/frankenphp/html:/usr/share/frankenphp/html:ro  # :ro = read-only

nginx:
  volumes:
    - ./services/nginx/html:/usr/share/nginx/html:ro
```

**Result:** You can modify `index.html` and see changes **immediately** without rebuild!

---

### 5. **Service Ports**

**⚠️ ATTENTION:** Ports have been corrected to avoid conflicts:

| Service | Port | URL |
|---------|------|-----|
| **FrankenPHP** | 80, 443 | `http://localhost` |
| **Nginx** | 8080, 8443 | `http://localhost:8080` |
| **Adminer** | **8081** | `http://localhost:8081` |
| **Redis Commander** | **8082** | `http://localhost:8082` |
| **Mailhog** | 8025 | `http://localhost:8025` |
| **Dozzle** | 8888 | `http://localhost:8888` |
| **RabbitMQ** | 15672 | `http://localhost:15672` |
| **Meilisearch** | 7700 | `http://localhost:7700` |

**Major change:** Adminer on 8081 (was: 8082), Redis Commander on 8082 (was: conflict)

---

### 6. **Quick Start: Two Modes**

The `./quick-start.sh` script now offers **2 modes**:

#### **Mode 1: Fresh Installation** (new project)
```bash
./quick-start.sh
# Choose: 1) Fresh installation
# Choose PHP version
# Choose framework (Laravel/Symfony/PrestaShop)
# → Project created automatically
```

#### **Mode 2: Git Clone Setup** (existing project)
```bash
git clone https://github.com/user/phpmoddock-lite.git
cd phpmoddock-lite

# Clone your existing project
git clone https://github.com/user/my-laravel-app.git projects/my-app

# Run setup
./quick-start.sh
# Choose: 2) Git clone setup
# → Auto-detects framework
# → Guides you through Caddyfile + hosts configuration
```

---

### 7. **Recommended Workflow for Adding a Project**

**Option A: Via Script (Recommended)**
```bash
./scripts/new-project.sh laravel my-new-app
# ✅ Everything configured automatically
```

**Option B: Existing Project**
```bash
# 1. Copy/clone into projects/
cp -r ~/my-existing-app ./projects/my-app

# 2. Add to Caddyfile
nano services/frankenphp/config/Caddyfile
# Add appropriate server block

# 3. Rebuild FrankenPHP (CRITICAL!)
docker-compose build frankenphp
docker-compose up -d frankenphp

# 4. Add to /etc/hosts
./scripts/hosts-manager.sh add my-app.localhost
```

---

### 8. **Service Health Check**

The welcome page displays **real-time status** of each service:

- 🟢 **Pulsing green** = Service active
- 🔴 **Red** = Service down
- ⚪ **Gray** = Checking

**Auto-refresh:** Every 30 seconds
**Technique:** Uses `fetch()` with `no-cors` mode to test ports

---

## 🔒 Security for Nomadic Developers

**⚠️ ATTENTION**: If you work from cafés, coworking spaces, or public WiFi:

### 1. **Ports Exposed on Localhost Only**

By default, PHPModDock-Lite exposes all ports on `127.0.0.1` (localhost only):

```yaml
# docker-compose.yml - Secure configuration
mysql:
  ports:
    - "127.0.0.1:3306:3306"  # ✅ Accessible only from your machine

# DANGEROUS configuration to avoid:
mysql:
  ports:
    - "3306:3306"  # ❌ Exposed to entire local network!
```

**Why this matters:**
- On public WiFi, `0.0.0.0:3306` = exposed to all network clients
- Someone on the same WiFi could scan ports and attempt connections
- With default passwords, this is a major security flaw

### 2. **Change Default Passwords**

The `.env.example` file contains passwords marked `CHANGE_ME_`:

```bash
# .env
MYSQL_PASSWORD=CHANGE_ME_secret         # ⚠️ Change immediately!
MYSQL_ROOT_PASSWORD=CHANGE_ME_root      # ⚠️ Change immediately!
POSTGRES_PASSWORD=CHANGE_ME_secret      # ⚠️ Change immediately!
RABBITMQ_DEFAULT_PASS=CHANGE_ME_guest   # ⚠️ Change immediately!
```

**Generate strong passwords:**
```bash
# Linux/macOS
openssl rand -hex 16

# Or use a password manager
```

### 3. **Personal Firewall Recommended**

On macOS/Linux, enable your firewall:

```bash
# macOS
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Linux (ufw)
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow ssh
```

### 4. **VPN for Maximum Security**

On public WiFi, **ALWAYS** use a VPN:
- Encrypts all your network traffic
- Prevents man-in-the-middle attacks
- Protects against packet sniffing

### 5. **Verify Exposed Ports**

Before connecting to public WiFi:

```bash
# Check which ports are exposed
docker-compose ps

# Check port bindings
docker-compose config | grep ports -A 2

# All ports should start with "127.0.0.1:"
```

### 6. **HTTPS Only for Projects**

FrankenPHP supports HTTPS automatically. Use it:

```caddyfile
# Caddyfile - Automatic HTTPS
https://myapp.localhost {
    # Caddy automatically generates certificates
}
```

---

## 📋 Startup Checklist

Before starting, ensure:

- [ ] Docker is installed and running
- [ ] Docker Compose is installed
- [ ] You have sudo rights (for /etc/hosts)
- [ ] The `.env` file exists (copied from `.env.example`)
- [ ] Profiles are configured: `COMPOSE_PROFILES=frankenphp,development`

---

## 🔧 Essential Commands

```bash
# Startup
make up                    # Start FrankenPHP stack
make workspace             # Enter dev container

# Project management
./scripts/new-project.sh laravel my-app      # New Laravel
./scripts/new-project.sh symfony my-api      # New Symfony
./scripts/new-project.sh prestashop my-shop  # New PrestaShop

# After Caddyfile modification
docker-compose build frankenphp
docker-compose up -d frankenphp

# Hosts management
./scripts/hosts-manager.sh add myapp.localhost
./scripts/hosts-manager.sh list
./scripts/hosts-manager.sh remove myapp.localhost

# Logs
make logs                  # All logs
docker-compose logs -f frankenphp  # FrankenPHP logs only
```

---

## ⚡ Quick Troubleshooting

### Problem: Blank page on my project
**Probable cause:** Caddyfile modified but not rebuilt
**Solution:**
```bash
docker-compose build frankenphp
docker-compose up -d frankenphp
```

### Problem: "Connection refused" on a service
**Solution:**
1. Check service is started: `docker-compose ps`
2. Check logs: `docker-compose logs <service>`
3. Restart: `docker-compose restart <service>`

### Problem: Project not visible on http://localhost
**Solution:**
1. Click "Refresh" in "Your Projects" section
2. Verify project is in `./projects/`
3. Check API logs: `curl http://localhost/api/projects.php`

### Problem: Permission denied in container
**Solution:**
```bash
# In workspace
cd /var/www/my-project
chmod -R 775 storage bootstrap/cache  # Laravel
chmod -R 775 var/                      # Symfony
```

---

## 📚 Additional Documentation

- **README.md**: Overview and quick start
- **CHANGELOG.md**: Version history
- **docs/**: Complete documentation (English + French)
  - `docs/en/guides/NEW_PROJECT_GUIDE.md`
  - `docs/fr/guides/FRANKENPHP_MULTI_PROJECT.md`

---

## 🆘 Support

If you encounter a problem:

1. Check this file first
2. Check CHANGELOG.md for recent changes
3. Read logs: `docker-compose logs`
4. Open a GitHub issue with:
   - Docker / Docker Compose version
   - OS used
   - Complete error logs

---

**Last updated:** 2025-10-26 - Version 0.1.0
