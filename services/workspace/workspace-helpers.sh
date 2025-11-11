#!/bin/bash

# PHPModDock-Lite - Workspace Helper Functions
# Universal helpers that work across all projects

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Detect current framework
detect_framework() {
    local current_dir=$(pwd)

    if [ -f "$current_dir/artisan" ]; then
        echo "laravel"
    elif [ -f "$current_dir/bin/console" ]; then
        echo "symfony"
    elif [ -f "$current_dir/composer.json" ]; then
        echo "php"
    else
        echo "unknown"
    fi
}

# Project navigation helper
project() {
    local cmd=$1
    local base_dir="/var/www"

    case "$cmd" in
        laravel|l)
            if [ -d "$base_dir/laravel-app" ]; then
                cd "$base_dir/laravel-app"
                echo -e "${GREEN}✓ Switched to Laravel project${NC}"
                ls -la
            else
                echo -e "${RED}✗ Laravel project not found at $base_dir/laravel-app${NC}"
            fi
            ;;

        symfony|s)
            if [ -d "$base_dir/symfony-api" ]; then
                cd "$base_dir/symfony-api"
                echo -e "${GREEN}✓ Switched to Symfony project${NC}"
                ls -la
            else
                echo -e "${RED}✗ Symfony project not found at $base_dir/symfony-api${NC}"
            fi
            ;;

        root|r)
            cd "$base_dir"
            echo -e "${CYAN}✓ Switched to root directory${NC}"
            ls -la
            ;;

        list|ls)
            echo -e "${BLUE}Available projects:${NC}"
            echo ""

            for dir in $base_dir/*/; do
                if [ -d "$dir" ]; then
                    dir=${dir%/}
                    dir_name=$(basename "$dir")

                    # Detect framework
                    local framework=""
                    if [ -f "$dir/artisan" ]; then
                        framework="${MAGENTA}[Laravel]${NC}"
                    elif [ -f "$dir/bin/console" ]; then
                        framework="${MAGENTA}[Symfony]${NC}"
                    elif [ -f "$dir/composer.json" ]; then
                        framework="${CYAN}[PHP]${NC}"
                    else
                        continue
                    fi

                    echo -e "  ${GREEN}•${NC} $dir_name $framework"
                    echo -e "    ${BLUE}$dir${NC}"
                    echo ""
                fi
            done
            ;;

        current|pwd)
            local framework=$(detect_framework)
            local current=$(pwd)

            echo -e "${BLUE}Current location:${NC} $current"

            case "$framework" in
                laravel)
                    echo -e "${MAGENTA}Framework:${NC} Laravel"
                    ;;
                symfony)
                    echo -e "${MAGENTA}Framework:${NC} Symfony"
                    ;;
                php)
                    echo -e "${MAGENTA}Framework:${NC} PHP (Generic)"
                    ;;
                *)
                    echo -e "${YELLOW}Framework:${NC} Unknown (not in a project)"
                    ;;
            esac
            ;;

        help|--help|-h|"")
            echo -e "${BLUE}Project Navigation Helper${NC}"
            echo ""
            echo -e "${YELLOW}Usage:${NC}"
            echo -e "  ${GREEN}project laravel${NC}   - Switch to Laravel project"
            echo -e "  ${GREEN}project symfony${NC}   - Switch to Symfony project"
            echo -e "  ${GREEN}project root${NC}      - Go to /var/www root"
            echo -e "  ${GREEN}project list${NC}      - List all available projects"
            echo -e "  ${GREEN}project current${NC}   - Show current project info"
            echo ""
            echo -e "${YELLOW}Shortcuts:${NC}"
            echo -e "  ${GREEN}project l${NC}  - Laravel"
            echo -e "  ${GREEN}project s${NC}  - Symfony"
            echo -e "  ${GREEN}project r${NC}  - Root"
            ;;

        *)
            # Try to find project by name
            if [ -d "$base_dir/$cmd" ]; then
                cd "$base_dir/$cmd"
                echo -e "${GREEN}✓ Switched to $cmd${NC}"
                ls -la
            else
                echo -e "${RED}✗ Unknown project: $cmd${NC}"
                echo -e "${YELLOW}Run 'project list' to see available projects${NC}"
            fi
            ;;
    esac
}

# Intelligent run helper
run() {
    local cmd=$1
    shift
    local args=$@
    local framework=$(detect_framework)

    case "$cmd" in
        migrate|migration)
            case "$framework" in
                laravel)
                    php artisan migrate $args
                    ;;
                symfony)
                    php bin/console doctrine:migrations:migrate $args
                    ;;
                *)
                    echo -e "${RED}✗ Not in a Laravel or Symfony project${NC}"
                    return 1
                    ;;
            esac
            ;;

        cache:clear|cache-clear|cc)
            case "$framework" in
                laravel)
                    php artisan cache:clear $args
                    ;;
                symfony)
                    php bin/console cache:clear $args
                    ;;
                *)
                    echo -e "${RED}✗ Not in a Laravel or Symfony project${NC}"
                    return 1
                    ;;
            esac
            ;;

        test|tests)
            case "$framework" in
                laravel)
                    if [ -f "./vendor/bin/pest" ]; then
                        ./vendor/bin/pest $args
                    else
                        php artisan test $args
                    fi
                    ;;
                symfony)
                    php bin/phpunit $args
                    ;;
                *)
                    echo -e "${RED}✗ Not in a Laravel or Symfony project${NC}"
                    return 1
                    ;;
            esac
            ;;

        composer|c)
            composer $args
            ;;

        npm|yarn|pnpm)
            $cmd $args
            ;;

        help|--help|-h|"")
            echo -e "${BLUE}Intelligent Run Helper${NC}"
            echo ""
            echo -e "${YELLOW}Usage:${NC}"
            echo -e "  ${GREEN}run migrate${NC}        - Run migrations (auto-detects framework)"
            echo -e "  ${GREEN}run cache:clear${NC}    - Clear cache (auto-detects framework)"
            echo -e "  ${GREEN}run test${NC}           - Run tests (auto-detects test runner)"
            echo -e "  ${GREEN}run composer ...${NC}   - Run composer commands"
            echo -e "  ${GREEN}run npm ...${NC}        - Run npm commands"
            echo ""
            echo -e "${YELLOW}Framework Detection:${NC}"
            echo -e "  Current: ${MAGENTA}$framework${NC}"
            ;;

        *)
            # Try framework-specific command
            case "$framework" in
                laravel)
                    php artisan "$cmd" $args
                    ;;
                symfony)
                    php bin/console "$cmd" $args
                    ;;
                *)
                    echo -e "${RED}✗ Unknown command: $cmd${NC}"
                    echo -e "${YELLOW}Run 'run help' for available commands${NC}"
                    return 1
                    ;;
            esac
            ;;
    esac
}

# Quick status info
workspace-info() {
    local framework=$(detect_framework)
    local current=$(pwd)

    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Workspace Information              ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}Location:${NC}     $current"

    case "$framework" in
        laravel)
            echo -e "${BLUE}Framework:${NC}    ${MAGENTA}Laravel${NC}"
            if [ -f "composer.json" ]; then
                local version=$(php artisan --version 2>/dev/null | grep -oP 'Laravel Framework \K[0-9.]+')
                if [ -n "$version" ]; then
                    echo -e "${BLUE}Version:${NC}      Laravel $version"
                fi
            fi
            ;;
        symfony)
            echo -e "${BLUE}Framework:${NC}    ${MAGENTA}Symfony${NC}"
            if [ -f "bin/console" ]; then
                local version=$(php bin/console --version 2>/dev/null | grep -oP 'Symfony \K[0-9.]+')
                if [ -n "$version" ]; then
                    echo -e "${BLUE}Version:${NC}      Symfony $version"
                fi
            fi
            ;;
        php)
            echo -e "${BLUE}Framework:${NC}    ${CYAN}PHP (Generic)${NC}"
            ;;
        *)
            echo -e "${BLUE}Framework:${NC}    ${YELLOW}Not in a project${NC}"
            ;;
    esac

    echo -e "${BLUE}PHP Version:${NC}  $(php -v | head -n 1 | awk '{print $2}')"

    if command -v node &> /dev/null; then
        echo -e "${BLUE}Node.js:${NC}      $(node -v)"
    fi

    if command -v composer &> /dev/null; then
        echo -e "${BLUE}Composer:${NC}     $(composer --version | grep -oP 'Composer version \K[0-9.]+')"
    fi

    echo ""
    echo -e "${YELLOW}Quick commands:${NC}"
    echo -e "  ${GREEN}project list${NC}    - List all projects"
    echo -e "  ${GREEN}project laravel${NC} - Switch to Laravel"
    echo -e "  ${GREEN}project symfony${NC} - Switch to Symfony"
    echo ""
}

# Alias for info
alias ws-info='workspace-info'
alias wsinfo='workspace-info'
