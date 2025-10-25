#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CADDYFILE_DIR="$PROJECT_ROOT/services/frankenphp/config"
CADDYFILE_HTTP="$CADDYFILE_DIR/Caddyfile"
CADDYFILE_HTTPS="$CADDYFILE_DIR/Caddyfile.https"
CONTAINER_NAME="laradock_frankenphp"

# Functions
print_info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_files() {
    if [[ ! -f "$CADDYFILE_HTTP" ]]; then
        print_error "HTTP Caddyfile not found: $CADDYFILE_HTTP"
        exit 1
    fi

    if [[ ! -f "$CADDYFILE_HTTPS" ]]; then
        print_error "HTTPS Caddyfile not found: $CADDYFILE_HTTPS"
        exit 1
    fi
}

get_current_mode() {
    if grep -q "^http://" "$CADDYFILE_HTTP"; then
        echo "http"
    else
        echo "https"
    fi
}

enable_https() {
    print_info "Switching to HTTPS mode..."

    # Backup current Caddyfile
    cp "$CADDYFILE_HTTP" "$CADDYFILE_HTTP.backup"
    print_success "Current Caddyfile backed up"

    # Copy HTTPS config
    cp "$CADDYFILE_HTTPS" "$CADDYFILE_HTTP"
    print_success "HTTPS Caddyfile activated"

    # Restart FrankenPHP container
    print_info "Restarting FrankenPHP container..."
    cd "$PROJECT_ROOT"
    docker-compose restart frankenphp

    print_success "HTTPS mode enabled!"
    echo ""
    print_info "Your applications are now accessible at:"
    echo "  • https://laravel-app.localhost"
    echo "  • https://symfony-api.localhost"
    echo ""
    print_warning "Note: You may see certificate warnings in your browser"
    print_info "To trust the certificates, run: docker exec $CONTAINER_NAME caddy trust"
}

disable_https() {
    print_info "Switching to HTTP mode..."

    # Check if backup exists, otherwise use the .https file as reference
    if [[ -f "$CADDYFILE_HTTP.backup" ]]; then
        # Check if backup is HTTP mode
        if grep -q "auto_https off" "$CADDYFILE_HTTP.backup"; then
            cp "$CADDYFILE_HTTP.backup" "$CADDYFILE_HTTP"
            print_success "HTTP Caddyfile restored from backup"
        else
            print_warning "Backup is not HTTP mode, using default HTTP config"
            # Create HTTP config from scratch
            cat > "$CADDYFILE_HTTP" << 'EOF'
# FrankenPHP Caddyfile - Multi-Project HTTP Mode
# Official documentation: https://frankenphp.dev/fr/docs/config/
# Switch to HTTPS: ./scripts/frankenphp-https.sh enable

{
	# Global options - HTTP only mode
	auto_https off

	# Enable FrankenPHP module
	frankenphp {
		# Number of PHP worker processes (optional)
		# Uncomment and adjust based on your needs
		# num_threads {$FRANKENPHP_NUM_THREADS:2}
	}
}

# Laravel Application - HTTP only
http://laravel-app.localhost {
	# Root directory for Laravel
	root * /var/www/laravel-app/public

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

# Symfony Application - HTTP only
http://symfony-api.localhost {
	# Root directory for Symfony
	root * /var/www/symfony-api/public

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
            print_success "Default HTTP Caddyfile created"
        fi
    else
        print_warning "No backup found, using default HTTP config"
        # Create HTTP config from scratch (same as above)
        cat > "$CADDYFILE_HTTP" << 'EOF'
# FrankenPHP Caddyfile - Multi-Project HTTP Mode
# Official documentation: https://frankenphp.dev/fr/docs/config/
# Switch to HTTPS: ./scripts/frankenphp-https.sh enable

{
	# Global options - HTTP only mode
	auto_https off

	# Enable FrankenPHP module
	frankenphp {
		# Number of PHP worker processes (optional)
		# Uncomment and adjust based on your needs
		# num_threads {$FRANKENPHP_NUM_THREADS:2}
	}
}

# Laravel Application - HTTP only
http://laravel-app.localhost {
	# Root directory for Laravel
	root * /var/www/laravel-app/public

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

# Symfony Application - HTTP only
http://symfony-api.localhost {
	# Root directory for Symfony
	root * /var/www/symfony-api/public

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
        print_success "Default HTTP Caddyfile created"
    fi

    # Clear Caddy cache to remove HTTPS redirects
    print_info "Clearing Caddy cache..."
    docker exec "$CONTAINER_NAME" rm -rf /data/caddy || true

    # Restart FrankenPHP container
    print_info "Restarting FrankenPHP container..."
    cd "$PROJECT_ROOT"
    docker-compose restart frankenphp

    print_success "HTTP mode enabled!"
    echo ""
    print_info "Your applications are now accessible at:"
    echo "  • http://laravel-app.localhost"
    echo "  • http://symfony-api.localhost"
}

show_status() {
    local mode=$(get_current_mode)

    echo ""
    print_info "FrankenPHP HTTPS Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ "$mode" == "https" ]]; then
        echo -e "Mode: ${GREEN}HTTPS${NC}"
        echo ""
        echo "Applications:"
        echo "  • https://laravel-app.localhost"
        echo "  • https://symfony-api.localhost"
    else
        echo -e "Mode: ${BLUE}HTTP${NC}"
        echo ""
        echo "Applications:"
        echo "  • http://laravel-app.localhost"
        echo "  • http://symfony-api.localhost"
    fi

    echo ""
    echo "Switch mode:"
    echo "  • Enable HTTPS:  ./scripts/frankenphp-https.sh enable"
    echo "  • Disable HTTPS: ./scripts/frankenphp-https.sh disable"
    echo ""
}

show_help() {
    cat << EOF
FrankenPHP HTTPS Mode Switcher

Usage: $0 [command]

Commands:
    enable      Switch to HTTPS mode with automatic certificates
    disable     Switch to HTTP-only mode (no redirects)
    status      Show current mode
    help        Show this help message

Examples:
    $0 enable       # Enable HTTPS mode
    $0 disable      # Switch back to HTTP mode
    $0 status       # Check current configuration

EOF
}

# Main
main() {
    check_files

    case "${1:-}" in
        enable)
            enable_https
            ;;
        disable)
            disable_https
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Invalid command: ${1:-}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
