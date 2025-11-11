#!/usr/bin/env bash

###########################################################
# Web Server Selection Menu
# Interactive script to choose between FrankenPHP and Nginx+PHP-FPM
###########################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           🚀 PHPModDock-Lite - Web Server Selection            ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Show menu
show_menu() {
    echo -e "${YELLOW}Choose your web server stack:${NC}\n"

    echo -e "${GREEN}[1]${NC} ${CYAN}FrankenPHP${NC} ${BLUE}(Recommended)${NC}"
    echo -e "    ⚡ Modern PHP application server"
    echo -e "    ✅ HTTP/2, HTTP/3, Worker mode"
    echo -e "    ✅ 3-4x faster than traditional stack"
    echo -e "    ✅ Perfect for Laravel & Symfony"
    echo ""

    echo -e "${GREEN}[2]${NC} ${CYAN}Nginx + PHP-FPM${NC} ${BLUE}(Traditional)${NC}"
    echo -e "    🔧 Classic battle-tested stack"
    echo -e "    ✅ Widely documented"
    echo -e "    ✅ Good for compatibility testing"
    echo -e "    ⚠️  Lower performance than FrankenPHP"
    echo ""

    echo -e "${GREEN}[0]${NC} Exit"
    echo ""
}

# Get current running services
get_running_services() {
    if docker ps --format '{{.Names}}' | grep -q "phpmoddock_frankenphp"; then
        echo "frankenphp"
    elif docker ps --format '{{.Names}}' | grep -q "phpmoddock_nginx"; then
        echo "nginx"
    else
        echo "none"
    fi
}

# Show current status
show_status() {
    local current=$(get_running_services)

    if [ "$current" = "frankenphp" ]; then
        echo -e "${BLUE}ℹ Current:${NC} FrankenPHP is running"
    elif [ "$current" = "nginx" ]; then
        echo -e "${BLUE}ℹ Current:${NC} Nginx + PHP-FPM is running"
    else
        echo -e "${BLUE}ℹ Current:${NC} No web server is running"
    fi
    echo ""
}

# Start FrankenPHP
start_frankenphp() {
    echo -e "${GREEN}🚀 Starting FrankenPHP stack...${NC}\n"

    # Stop nginx if running
    docker-compose stop nginx php-fpm 2>/dev/null

    # Start FrankenPHP
    COMPOSE_PROFILES=frankenphp docker-compose up -d frankenphp workspace mysql redis meilisearch rabbitmq mailhog adminer dozzle

    echo ""
    echo -e "${GREEN}✅ FrankenPHP stack started!${NC}\n"
    echo -e "${YELLOW}Access points:${NC}"
    echo -e "  ${CYAN}Application:${NC}      http://localhost"
    echo -e "  ${CYAN}FrankenPHP:${NC}       http://localhost:80"
    echo -e "  ${CYAN}Adminer:${NC}          http://localhost:8081"
    echo -e "  ${CYAN}Mailhog:${NC}          http://localhost:8025"
    echo -e "  ${CYAN}Dozzle:${NC}           http://localhost:8888"
    echo -e "  ${CYAN}RabbitMQ:${NC}         http://localhost:15672"
    echo ""
}

# Start Nginx + PHP-FPM
start_nginx() {
    echo -e "${GREEN}🔧 Starting Nginx + PHP-FPM stack...${NC}\n"

    # Stop frankenphp if running
    docker-compose stop frankenphp 2>/dev/null

    # Start Nginx + PHP-FPM
    COMPOSE_PROFILES=nginx,php-fpm docker-compose up -d nginx php-fpm workspace mysql redis meilisearch rabbitmq mailhog adminer dozzle

    echo ""
    echo -e "${GREEN}✅ Nginx + PHP-FPM stack started!${NC}\n"
    echo -e "${YELLOW}Access points:${NC}"
    echo -e "  ${CYAN}Application:${NC}      http://localhost"
    echo -e "  ${CYAN}Nginx:${NC}            http://localhost:80"
    echo -e "  ${CYAN}Adminer:${NC}          http://localhost:8081"
    echo -e "  ${CYAN}Mailhog:${NC}          http://localhost:8025"
    echo -e "  ${CYAN}Dozzle:${NC}           http://localhost:8888"
    echo -e "  ${CYAN}RabbitMQ:${NC}         http://localhost:15672"
    echo ""
}

# Main menu loop
main() {
    show_banner
    show_status
    show_menu

    echo -n -e "${GREEN}Your choice [0-2]: ${NC}"
    read choice

    case "$choice" in
        1)
            echo ""
            start_frankenphp
            ;;
        2)
            echo ""
            start_nginx
            ;;
        0)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select 1, 2, or 0.${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main
