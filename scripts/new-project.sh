#!/usr/bin/env bash

# PHPModDock-Lite - New Project Creator
# Création automatique de projets Laravel/Symfony avec configuration complète

set -euo pipefail

# Load libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/os-detection.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECTS_DIR="$PROJECT_ROOT/projects"
CADDYFILE="$PROJECT_ROOT/services/frankenphp/config/Caddyfile"
HOSTS_MANAGER="$SCRIPT_DIR/hosts-manager.sh"

# Functions
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║                                                    ║"
    echo "║    PHPModDock-Lite - New Project Creator            ║"
    echo "║                                                    ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_help() {
    cat << EOF
${BLUE}PHPModDock-Lite - New Project Creator${NC}

${YELLOW}Usage:${NC}
  $0 <framework> <project-name> [options]

${YELLOW}Frameworks:${NC}
  ${GREEN}laravel${NC}      - Créer un projet Laravel
  ${GREEN}symfony${NC}      - Créer un projet Symfony
  ${GREEN}prestashop${NC}   - Créer un projet PrestaShop

${YELLOW}Options:${NC}
  ${GREEN}--domain <domain>${NC}     - Domaine custom (défaut: <project-name>.localhost)
  ${GREEN}--no-hosts${NC}            - Ne pas modifier /etc/hosts
  ${GREEN}--no-caddyfile${NC}        - Ne pas modifier Caddyfile
  ${GREEN}--skeleton${NC}             - Symfony: utiliser skeleton au lieu de webapp
  ${GREEN}--api${NC}                  - Laravel: API-only, Symfony: API Platform

${YELLOW}Exemples:${NC}

  # Laravel standard
  $0 laravel my-app

  # Laravel API
  $0 laravel api-backend --api

  # Symfony webapp
  $0 symfony my-api

  # Symfony skeleton (minimal)
  $0 symfony microservice --skeleton

  # Avec domaine custom
  $0 laravel shop --domain boutique.local

  # Sans modifier /etc/hosts (configuration manuelle)
  $0 symfony api --no-hosts

  # PrestaShop
  $0 prestashop my-shop

EOF
}

# Parse arguments
parse_args() {
    FRAMEWORK=""
    PROJECT_NAME=""
    DOMAIN=""
    MODIFY_HOSTS=true
    MODIFY_CADDYFILE=true
    PROJECT_TYPE="default"

    while [[ $# -gt 0 ]]; do
        case $1 in
            laravel|symfony|prestashop)
                FRAMEWORK=$1
                ;;
            --domain)
                DOMAIN=$2
                shift
                ;;
            --no-hosts)
                MODIFY_HOSTS=false
                ;;
            --no-caddyfile)
                MODIFY_CADDYFILE=false
                ;;
            --skeleton)
                PROJECT_TYPE="skeleton"
                ;;
            --api)
                PROJECT_TYPE="api"
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                if [ -z "$PROJECT_NAME" ]; then
                    PROJECT_NAME=$1
                else
                    echo -e "${RED}✗ Argument inconnu: $1${NC}"
                    exit 1
                fi
                ;;
        esac
        shift
    done

    # Validate
    if [ -z "$FRAMEWORK" ]; then
        echo -e "${RED}✗ Framework requis (laravel, symfony ou prestashop)${NC}"
        echo ""
        show_help
        exit 1
    fi

    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}✗ Nom de projet requis${NC}"
        echo ""
        show_help
        exit 1
    fi

    # Set default domain
    if [ -z "$DOMAIN" ]; then
        DOMAIN="${PROJECT_NAME}.localhost"
    fi
}

# Validate input to prevent command injection
validate_input() {
    # Validate project name: alphanumeric, hyphens, underscores only
    if ! [[ "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo -e "${RED}✗ Nom de projet invalide${NC}"
        echo -e "${YELLOW}Utilisez seulement des lettres, chiffres, tirets (-) et underscores (_)${NC}"
        exit 1
    fi

    # Validate domain name format
    if ! [[ "$DOMAIN" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$ ]]; then
        echo -e "${RED}✗ Nom de domaine invalide: $DOMAIN${NC}"
        echo -e "${YELLOW}Utilisez un format de domaine valide (ex: myapp.localhost)${NC}"
        exit 1
    fi
}

# Wait for container to be healthy
wait_for_healthy() {
    local container_name=$1
    local max_wait=${2:-30}
    local wait_time=0

    echo -e "${BLUE}Waiting for $container_name to be healthy...${NC}"

    while [ $wait_time -lt $max_wait ]; do
        if docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null | grep -q "healthy"; then
            echo -e "${GREEN}✓ $container_name is healthy${NC}"
            return 0
        fi

        # Also check if container is running but has no healthcheck
        if docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
            if ! docker inspect --format='{{.State.Health}}' "$container_name" 2>/dev/null | grep -q "Status"; then
                echo -e "${GREEN}✓ $container_name is running${NC}"
                return 0
            fi
        fi

        sleep 1
        wait_time=$((wait_time + 1))
    done

    echo -e "${YELLOW}⚠ Timeout waiting for $container_name${NC}"
    return 1
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}✗ Docker n'est pas démarré${NC}"
        echo ""
        echo -e "${YELLOW}Démarrez Docker et relancez ce script${NC}"
        exit 1
    fi
}

# Check if workspace container is running
check_workspace() {
    if ! docker ps --format '{{.Names}}' | grep -q "phpmoddock_workspace"; then
        echo -e "${YELLOW}⚠ Container workspace non démarré${NC}"
        echo ""
        echo -e "${BLUE}Démarrage du workspace...${NC}"
        cd "$PROJECT_ROOT"
        docker-compose up -d workspace
        wait_for_healthy "phpmoddock_workspace" 30 || true
    fi
}

# Create Laravel project
create_laravel() {
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"

    echo -e "${BLUE}Création du projet Laravel: $PROJECT_NAME${NC}"
    echo ""

    if [ -d "$project_path" ]; then
        echo -e "${RED}✗ Le projet existe déjà: $project_path${NC}"
        exit 1
    fi

    cd "$PROJECT_ROOT"

    # Create project based on type
    if [ "$PROJECT_TYPE" = "api" ]; then
        echo -e "${CYAN}→ Création d'un projet Laravel API-only...${NC}"
        docker-compose exec -w /var/www workspace \
            composer create-project laravel/laravel "$PROJECT_NAME" --prefer-dist

        # Install Sanctum
        echo -e "${CYAN}→ Installation de Laravel Sanctum...${NC}"
        docker-compose exec -w "/var/www/$PROJECT_NAME" workspace \
            composer require laravel/sanctum
    else
        echo -e "${CYAN}→ Création d'un projet Laravel standard...${NC}"
        docker-compose exec -w /var/www workspace \
            composer create-project laravel/laravel "$PROJECT_NAME" --prefer-dist
    fi

    # Set permissions
    echo -e "${CYAN}→ Configuration des permissions...${NC}"
    docker-compose exec -w "/var/www/$PROJECT_NAME" workspace \
        chmod -R 775 storage bootstrap/cache

    echo -e "${GREEN}✓ Projet Laravel créé${NC}"
}

# Create Symfony project
create_symfony() {
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"

    echo -e "${BLUE}Création du projet Symfony: $PROJECT_NAME${NC}"
    echo ""

    if [ -d "$project_path" ]; then
        echo -e "${RED}✗ Le projet existe déjà: $project_path${NC}"
        exit 1
    fi

    cd "$PROJECT_ROOT"

    # Create project based on type
    if [ "$PROJECT_TYPE" = "skeleton" ]; then
        echo -e "${CYAN}→ Création d'un projet Symfony skeleton (minimal)...${NC}"
        docker-compose exec -w /var/www workspace \
            symfony new "$PROJECT_NAME" --no-git
    elif [ "$PROJECT_TYPE" = "api" ]; then
        echo -e "${CYAN}→ Création d'un projet Symfony API Platform...${NC}"
        docker-compose exec -w /var/www workspace \
            symfony new "$PROJECT_NAME" --webapp --no-git

        # Install API Platform
        echo -e "${CYAN}→ Installation d'API Platform...${NC}"
        docker-compose exec -w "/var/www/$PROJECT_NAME" workspace \
            composer require api
    else
        echo -e "${CYAN}→ Création d'un projet Symfony webapp...${NC}"
        docker-compose exec -w /var/www workspace \
            symfony new "$PROJECT_NAME" --webapp --no-git
    fi

    # Set permissions
    echo -e "${CYAN}→ Configuration des permissions...${NC}"
    docker-compose exec -w "/var/www/$PROJECT_NAME" workspace \
        chmod -R 775 var/

    echo -e "${GREEN}✓ Projet Symfony créé${NC}"
}

# Create PrestaShop project
create_prestashop() {
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"

    echo -e "${BLUE}Création du projet PrestaShop: $PROJECT_NAME${NC}"
    echo ""

    if [ -d "$project_path" ]; then
        echo -e "${RED}✗ Le projet existe déjà: $project_path${NC}"
        exit 1
    fi

    cd "$PROJECT_ROOT"

    echo -e "${CYAN}→ Téléchargement de PrestaShop (latest)...${NC}"

    # Download PrestaShop
    docker-compose exec -w /var/www workspace \
        bash -c "mkdir -p $PROJECT_NAME && cd $PROJECT_NAME && \
        curl -L https://github.com/PrestaShop/PrestaShop/releases/download/8.2.0/prestashop_8.2.0.zip -o prestashop.zip && \
        unzip -o -q prestashop.zip && \
        unzip -o -q prestashop.zip && \
        rm -f prestashop.zip"

    # Set permissions
    echo -e "${CYAN}→ Configuration des permissions...${NC}"
    docker-compose exec -w "/var/www/$PROJECT_NAME" workspace \
        bash -c "chmod -R 775 . && \
        chmod -R 777 var/ cache/ log/ download/ upload/ img/ mails/ translations/ modules/ themes/ config/"

    echo -e "${GREEN}✓ Projet PrestaShop créé${NC}"
    echo -e "${YELLOW}⚠ Pour terminer l'installation:${NC}"
    echo -e "   1. Accédez à ${GREEN}http://$DOMAIN${NC}"
    echo -e "   2. Suivez l'assistant d'installation"
    echo -e "   3. Utilisez les credentials DB:"
    echo -e "      - Server: ${GREEN}mysql${NC}"
    echo -e "      - Database: ${GREEN}default${NC}"
    echo -e "      - Username: ${GREEN}default${NC}"
    echo -e "      - Password: ${GREEN}secret${NC}"
}

# Update Caddyfile
update_caddyfile() {
    if [ "$MODIFY_CADDYFILE" = false ]; then
        echo -e "${YELLOW}⊘ Modification Caddyfile ignorée (--no-caddyfile)${NC}"
        return 0
    fi

    echo -e "${BLUE}Mise à jour du Caddyfile...${NC}"

    # Backup Caddyfile
    cp "$CADDYFILE" "${CADDYFILE}.backup-$(date +%Y%m%d-%H%M%S)"

    # Add new server block
    local server_block=""
    if [ "$FRAMEWORK" = "laravel" ]; then
        server_block=$(cat << EOF

# $PROJECT_NAME - Laravel Application - HTTP only
http://$DOMAIN {
	# Root directory
	root * /var/www/$PROJECT_NAME/public

	# Enable compression
	encode zstd br gzip

	# Logging
	log {
		output stdout
		format console
		level {$LOG_LEVEL:INFO}
	}

	# PHP server directive
	php_server
}
EOF
)
    elif [ "$FRAMEWORK" = "prestashop" ]; then
        server_block=$(cat << EOF

# $PROJECT_NAME - PrestaShop Application - HTTP only
http://$DOMAIN {
	# Root directory
	root * /var/www/$PROJECT_NAME

	# Enable compression
	encode zstd br gzip

	# Logging
	log {
		output stdout
		format console
		level {$LOG_LEVEL:INFO}
	}

	# PHP server directive
	php_server
}
EOF
)
    else
        server_block=$(cat << EOF

# $PROJECT_NAME - Symfony Application - HTTP only
http://$DOMAIN {
	# Root directory
	root * /var/www/$PROJECT_NAME/public

	# Enable compression
	encode zstd br gzip

	# Logging
	log {
		output stdout
		format console
		level {$LOG_LEVEL:INFO}
	}

	# PHP server directive
	php_server
}
EOF
)
    fi

    # Append to Caddyfile
    echo "$server_block" >> "$CADDYFILE"

    echo -e "${GREEN}✓ Caddyfile mis à jour${NC}"
}

# Update /etc/hosts
update_hosts() {
    if [ "$MODIFY_HOSTS" = false ]; then
        echo -e "${YELLOW}⊘ Modification /etc/hosts ignorée (--no-hosts)${NC}"
        echo ""
        echo -e "${BLUE}Configuration manuelle requise:${NC}"
        echo -e "  Ajoutez à votre fichier hosts:"
        echo -e "  ${GREEN}127.0.0.1  $DOMAIN${NC}"
        return 0
    fi

    echo -e "${BLUE}Mise à jour de /etc/hosts...${NC}"

    # Use hosts manager
    "$HOSTS_MANAGER" add "$DOMAIN" "127.0.0.1" "$PROJECT_NAME - $FRAMEWORK"
}

# Restart FrankenPHP
restart_frankenphp() {
    echo -e "${BLUE}Redémarrage de FrankenPHP...${NC}"
    cd "$PROJECT_ROOT"
    docker-compose restart frankenphp
    wait_for_healthy "phpmoddock_frankenphp" 30 || true
    echo -e "${GREEN}✓ FrankenPHP redémarré${NC}"
}

# Print success message
print_success() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                    ║${NC}"
    echo -e "${GREEN}║              🎉 Projet Créé avec Succès !          ║${NC}"
    echo -e "${GREEN}║                                                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Informations du projet:${NC}"
    echo -e "${BLUE}  Framework:${NC}    $FRAMEWORK"
    echo -e "${BLUE}  Nom:${NC}          $PROJECT_NAME"
    echo -e "${BLUE}  Domaine:${NC}      $DOMAIN"
    echo -e "${BLUE}  Chemin:${NC}       $PROJECTS_DIR/$PROJECT_NAME"
    echo ""
    echo -e "${CYAN}Accès:${NC}"
    echo -e "  ${GREEN}http://$DOMAIN${NC}"
    echo ""
    echo -e "${CYAN}Prochaines étapes:${NC}"
    echo ""

    if [ "$FRAMEWORK" = "laravel" ]; then
        echo -e "${YELLOW}1. Configuration de la base de données:${NC}"
        echo -e "   ${BLUE}make workspace${NC}"
        echo -e "   ${BLUE}project $PROJECT_NAME${NC}"
        echo -e "   ${BLUE}nano .env${NC}  # Configurez DB_DATABASE, DB_USERNAME, DB_PASSWORD"
        echo ""
        echo -e "${YELLOW}2. Migrations:${NC}"
        echo -e "   ${BLUE}art migrate${NC}"
        echo ""
        echo -e "${YELLOW}3. Développement frontend:${NC}"
        echo -e "   ${BLUE}npm install${NC}"
        echo -e "   ${BLUE}npm run dev${NC}"
    else
        echo -e "${YELLOW}1. Configuration de la base de données:${NC}"
        echo -e "   ${BLUE}make workspace${NC}"
        echo -e "   ${BLUE}project $PROJECT_NAME${NC}"
        echo -e "   ${BLUE}nano .env${NC}  # Configurez DATABASE_URL"
        echo ""
        echo -e "${YELLOW}2. Créer une entité:${NC}"
        echo -e "   ${BLUE}sf make:entity${NC}"
        echo ""
        echo -e "${YELLOW}3. Migrations:${NC}"
        echo -e "   ${BLUE}sf doctrine:migrations:migrate${NC}"
    fi

    echo ""
    echo -e "${CYAN}Workspace:${NC}"
    echo -e "   ${BLUE}make workspace${NC}  puis choisissez votre projet dans le menu"
    echo ""
}

# Main
main() {
    parse_args "$@"
    validate_input

    print_banner
    print_os_info
    echo ""

    # Checks
    check_docker
    check_workspace

    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  Configuration${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}Framework:${NC}        $FRAMEWORK"
    echo -e "${BLUE}Nom du projet:${NC}    $PROJECT_NAME"
    echo -e "${BLUE}Domaine:${NC}          $DOMAIN"
    echo -e "${BLUE}Type:${NC}             $PROJECT_TYPE"
    echo -e "${BLUE}Modifier hosts:${NC}   $MODIFY_HOSTS"
    echo -e "${BLUE}Modifier Caddy:${NC}   $MODIFY_CADDYFILE"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""

    echo -e "${YELLOW}Continuer ? [Y/n]${NC} "
    read -r response
    if [[ "$response" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Annulé${NC}"
        exit 0
    fi

    echo ""

    # Create project
    if [ "$FRAMEWORK" = "laravel" ]; then
        create_laravel
    elif [ "$FRAMEWORK" = "symfony" ]; then
        create_symfony
    elif [ "$FRAMEWORK" = "prestashop" ]; then
        create_prestashop
    fi

    echo ""

    # Update configuration
    update_caddyfile
    update_hosts

    echo ""

    # Restart services
    restart_frankenphp

    # Success
    print_success
}

main "$@"
