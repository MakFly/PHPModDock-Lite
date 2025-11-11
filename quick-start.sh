#!/bin/bash

###########################################################
# PHPModDock-Lite - Quick Start Script
# Automated setup for new installations and cloned projects
###########################################################

set -euo pipefail

# Load libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/lib/os-detection.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

###########################################################
# Functions
###########################################################

print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║                                                    ║"
    echo "║        PHPModDock-Lite - Quick Start               ║"
    echo "║        Modern Docker Stack for PHP Development     ║"
    echo "║                                                    ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
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

check_requirements() {
    echo -e "${BLUE}Checking requirements...${NC}"
    echo ""

    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker is not installed${NC}"
        echo -e "${YELLOW}Please install Docker: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker installed${NC}"

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}✗ Docker Compose is not installed${NC}"
        echo -e "${YELLOW}Please install Docker Compose${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker Compose installed${NC}"

    # Check if Docker daemon is running
    if ! docker info &> /dev/null 2>&1; then
        echo -e "${RED}✗ Docker daemon is not running${NC}"
        echo -e "${YELLOW}Please start Docker and try again${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Docker daemon running${NC}"

    echo ""
}

setup_mode_selection() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Setup Mode Selection${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "1) Fresh installation (new project)"
    echo "2) Git clone setup (existing project)"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose setup mode [1-2]:${NC} )" setup_choice

    case $setup_choice in
        1)
            SETUP_MODE="fresh"
            echo -e "${GREEN}✓ Fresh installation mode${NC}"
            ;;
        2)
            SETUP_MODE="clone"
            echo -e "${GREEN}✓ Git clone setup mode${NC}"
            ;;
        *)
            echo -e "${RED}Invalid choice. Using fresh installation mode.${NC}"
            SETUP_MODE="fresh"
            ;;
    esac
    echo ""
}

create_env_file() {
    if [ ! -f .env ]; then
        echo -e "${YELLOW}Creating .env file...${NC}"
        cp .env.example .env
        echo -e "${GREEN}✓ .env file created${NC}"
    else
        echo -e "${YELLOW}.env file already exists${NC}"
        read -p "$(echo -e ${YELLOW}Do you want to reset it? [y/N]:${NC} )" reset_env
        if [[ "$reset_env" =~ ^[Yy]$ ]]; then
            cp .env.example .env
            echo -e "${GREEN}✓ .env file reset${NC}"
        fi
    fi
    echo ""
}

select_php_version() {
    echo -e "${BLUE}Which PHP version would you like to use?${NC}"
    echo "1) PHP 8.3 (recommended)"
    echo "2) PHP 8.2"
    echo "3) PHP 8.1"
    echo ""
    read -p "$(echo -e ${YELLOW}Enter your choice [1-3]:${NC} )" php_choice

    case $php_choice in
        1)
            PHP_VERSION="8.3"
            ;;
        2)
            PHP_VERSION="8.2"
            ;;
        3)
            PHP_VERSION="8.1"
            ;;
        *)
            PHP_VERSION="8.3"
            echo -e "${YELLOW}Invalid choice. Using PHP 8.3${NC}"
            ;;
    esac

    # Update .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^PHP_VERSION=.*/PHP_VERSION=$PHP_VERSION/" .env
    else
        sed -i "s/^PHP_VERSION=.*/PHP_VERSION=$PHP_VERSION/" .env
    fi

    echo -e "${GREEN}✓ PHP $PHP_VERSION selected${NC}"
    echo ""
}

create_directories() {
    echo -e "${YELLOW}Creating necessary directories...${NC}"

    mkdir -p projects
    mkdir -p logs/nginx
    mkdir -p services/mysql/docker-entrypoint-initdb.d
    mkdir -p services/postgres/docker-entrypoint-initdb.d

    echo -e "${GREEN}✓ Directories created${NC}"
    echo ""
}

build_containers() {
    echo -e "${YELLOW}Building Docker containers...${NC}"
    echo -e "${BLUE}This may take a few minutes on first run...${NC}"
    echo ""

    # Build FrankenPHP (includes Caddyfile)
    docker-compose build frankenphp workspace

    echo ""
    echo -e "${GREEN}✓ Containers built successfully${NC}"
    echo ""
}

start_containers() {
    echo -e "${YELLOW}Starting containers...${NC}"

    # Start with FrankenPHP profile + development services
    COMPOSE_PROFILES=frankenphp,development docker-compose up -d

    echo ""
    echo -e "${GREEN}✓ Containers started successfully${NC}"
    echo ""

    # Wait for services
    echo -e "${BLUE}Waiting for services to be ready...${NC}"
    wait_for_healthy "phpmoddock_workspace" 30 || true
    echo ""
}

setup_fresh_project() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Framework Selection${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "1) Laravel"
    echo "2) Symfony"
    echo "3) PrestaShop"
    echo "4) Skip (configure manually later)"
    echo ""
    read -p "$(echo -e ${YELLOW}Choose framework [1-4]:${NC} )" framework_choice

    case $framework_choice in
        1)
            echo ""
            read -p "$(echo -e ${YELLOW}Project name (e.g., my-app):${NC} )" project_name
            if [ ! -z "$project_name" ]; then
                echo -e "${BLUE}Creating Laravel project...${NC}"
                ./scripts/new-project.sh laravel "$project_name"
            fi
            ;;
        2)
            echo ""
            read -p "$(echo -e ${YELLOW}Project name (e.g., my-api):${NC} )" project_name
            if [ ! -z "$project_name" ]; then
                echo -e "${BLUE}Creating Symfony project...${NC}"
                ./scripts/new-project.sh symfony "$project_name"
            fi
            ;;
        3)
            echo ""
            read -p "$(echo -e ${YELLOW}Project name (e.g., my-shop):${NC} )" project_name
            if [ ! -z "$project_name" ]; then
                echo -e "${BLUE}Creating PrestaShop project...${NC}"
                ./scripts/new-project.sh prestashop "$project_name"
            fi
            ;;
        *)
            echo -e "${YELLOW}⊘ Skipping project creation${NC}"
            ;;
    esac
    echo ""
}

setup_cloned_project() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Existing Project Setup${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""

    # Check for existing projects
    if [ -d "projects" ] && [ "$(ls -A projects 2>/dev/null)" ]; then
        echo -e "${GREEN}Found existing projects in ./projects:${NC}"
        ls -1 projects/
        echo ""
    else
        echo -e "${YELLOW}No projects found in ./projects${NC}"
        echo ""
        echo -e "${BLUE}To add your project:${NC}"
        echo "1. Place your project in ./projects/ directory"
        echo "2. Run: ./scripts/new-project.sh <framework> <project-name> --no-caddyfile --no-hosts"
        echo "3. Or manually add to Caddyfile and /etc/hosts"
        echo ""
        return
    fi

    # Detect projects and offer to configure
    echo -e "${YELLOW}Would you like to configure Caddyfile and hosts for existing projects?${NC}"
    read -p "$(echo -e ${YELLOW}[Y/n]:${NC} )" configure_choice

    if [[ ! "$configure_choice" =~ ^[Nn]$ ]]; then
        for project in projects/*/ ; do
            if [ -d "$project" ]; then
                project_name=$(basename "$project")
                echo ""
                echo -e "${BLUE}Configuring: $project_name${NC}"

                # Auto-detect framework
                if [ -f "$project/artisan" ]; then
                    framework="laravel"
                elif [ -f "$project/symfony.lock" ]; then
                    framework="symfony"
                elif [ -f "$project/classes/PrestaShopAutoload.php" ]; then
                    framework="prestashop"
                else
                    framework="generic"
                fi

                echo -e "${GREEN}Detected framework: $framework${NC}"

                # Use new-project.sh to configure (without creating project)
                # This would need a new flag in new-project.sh
                echo -e "${YELLOW}Please manually configure this project using:${NC}"
                echo -e "  ${CYAN}./scripts/new-project.sh $framework $project_name --no-create${NC}"
            fi
        done
    fi
    echo ""
}

print_success() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                    ║${NC}"
    echo -e "${GREEN}║            🎉 Setup Complete!                      ║${NC}"
    echo -e "${GREEN}║                                                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""

    print_os_info
    echo ""

    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  Access Points${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Services:${NC}"
    echo -e "  Welcome Page:    ${BLUE}http://localhost${NC}"
    echo -e "  Adminer:         ${BLUE}http://localhost:8081${NC}"
    echo -e "  Redis Commander: ${BLUE}http://localhost:8082${NC}"
    echo -e "  Mailhog:         ${BLUE}http://localhost:8025${NC}"
    echo -e "  Dozzle (Logs):   ${BLUE}http://localhost:8888${NC}"
    echo -e "  RabbitMQ:        ${BLUE}http://localhost:15672${NC} (guest/guest)"
    echo -e "  Meilisearch:     ${BLUE}http://localhost:7700${NC}"
    echo ""

    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  Quick Commands${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Workspace:${NC}"
    echo -e "  ${BLUE}make workspace${NC}       - Enter development container"
    echo ""
    echo -e "${YELLOW}Project Management:${NC}"
    echo -e "  ${BLUE}./scripts/new-project.sh laravel my-app${NC}    - Create Laravel project"
    echo -e "  ${BLUE}./scripts/new-project.sh symfony my-api${NC}    - Create Symfony project"
    echo -e "  ${BLUE}./scripts/new-project.sh prestashop my-shop${NC} - Create PrestaShop"
    echo ""
    echo -e "${YELLOW}Container Management:${NC}"
    echo -e "  ${BLUE}make up${NC}              - Start containers"
    echo -e "  ${BLUE}make down${NC}            - Stop containers"
    echo -e "  ${BLUE}make restart${NC}         - Restart containers"
    echo -e "  ${BLUE}make logs${NC}            - View logs"
    echo ""
    echo -e "${YELLOW}Hosts Management:${NC}"
    echo -e "  ${BLUE}./scripts/hosts-manager.sh add myapp.localhost${NC}    - Add host entry"
    echo -e "  ${BLUE}./scripts/hosts-manager.sh list${NC}                    - List all entries"
    echo ""

    if [ "$SETUP_MODE" = "fresh" ]; then
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${CYAN}  Next Steps${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo ""
        echo "1. Access the welcome page at ${GREEN}http://localhost${NC}"
        echo "2. Your projects will appear automatically"
        echo "3. Enter workspace: ${BLUE}make workspace${NC}"
        echo "4. Read the docs: ${BLUE}README.md${NC}"
        echo ""
    else
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo -e "${CYAN}  Next Steps${NC}"
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo ""
        echo "1. Configure your project domains in Caddyfile"
        echo "2. Add entries to /etc/hosts using hosts-manager.sh"
        echo "3. Rebuild FrankenPHP: ${BLUE}docker-compose build frankenphp${NC}"
        echo "4. Restart containers: ${BLUE}make restart${NC}"
        echo ""
    fi

    echo -e "${GREEN}Happy coding! 🚀${NC}"
    echo ""
}

###########################################################
# Main Execution
###########################################################

main() {
    print_banner
    print_os_info
    echo ""

    # Check requirements
    check_requirements

    # Setup mode selection
    setup_mode_selection

    # Create .env file
    create_env_file

    # Select PHP version
    select_php_version

    # Create directories
    create_directories

    # Build containers
    build_containers

    # Start containers
    start_containers

    # Setup based on mode
    if [ "$SETUP_MODE" = "fresh" ]; then
        setup_fresh_project
    else
        setup_cloned_project
    fi

    # Print success message
    print_success
}

# Run main function
main "$@"
