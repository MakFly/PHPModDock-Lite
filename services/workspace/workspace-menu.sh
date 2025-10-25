#!/bin/bash

# PHPModDock-Lite - Workspace Interactive Menu
# Automatically detects projects and provides navigation

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
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════╗"
    echo "║                                                    ║"
    echo "║       PHPModDock-Lite - Workspace Menu              ║"
    echo "║                                                    ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detect available projects
detect_projects() {
    local projects=()
    local index=1

    if [ -d "/var/www/laravel-app" ]; then
        projects+=("$index:Laravel:/var/www/laravel-app")
        ((index++))
    fi

    if [ -d "/var/www/symfony-api" ]; then
        projects+=("$index:Symfony:/var/www/symfony-api")
        ((index++))
    fi

    # Add any other project directories found
    for dir in /var/www/*/; do
        dir=${dir%/}
        dir_name=$(basename "$dir")

        # Skip already added projects
        if [[ "$dir_name" != "laravel-app" && "$dir_name" != "symfony-api" ]]; then
            # Check if it's a PHP project (has composer.json)
            if [ -f "$dir/composer.json" ]; then
                projects+=("$index:$dir_name:$dir")
                ((index++))
            fi
        fi
    done

    echo "${projects[@]}"
}

# Show project menu
show_menu() {
    local projects=($@)
    local total=${#projects[@]}

    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}Aucun projet trouvé dans /var/www${NC}"
        echo -e "${BLUE}Astuce: Créez un projet Laravel ou Symfony pour commencer${NC}"
        echo ""
        return 1
    fi

    echo -e "${GREEN}Projets disponibles :${NC}"
    echo ""

    for project in "${projects[@]}"; do
        IFS=':' read -r num name path <<< "$project"

        # Detect framework
        local framework=""
        if [ -f "$path/artisan" ]; then
            framework="${MAGENTA}[Laravel]${NC}"
        elif [ -f "$path/bin/console" ]; then
            framework="${MAGENTA}[Symfony]${NC}"
        else
            framework="${CYAN}[PHP]${NC}"
        fi

        echo -e "  ${GREEN}[$num]${NC} $name $framework"
        echo -e "      ${BLUE}→ $path${NC}"
        echo ""
    done

    echo -e "  ${YELLOW}[0]${NC} Rester à la racine (/var/www)"
    echo ""
}

# Navigate to selected project
navigate_to_project() {
    local choice=$1
    shift
    local projects=($@)

    if [ "$choice" = "0" ]; then
        echo -e "${CYAN}Vous êtes dans /var/www${NC}"
        cd /var/www
        return 0
    fi

    for project in "${projects[@]}"; do
        IFS=':' read -r num name path <<< "$project"

        if [ "$num" = "$choice" ]; then
            cd "$path"

            # Show project info
            echo ""
            echo -e "${GREEN}✓ Projet sélectionné: $name${NC}"
            echo -e "${BLUE}  Répertoire: $path${NC}"

            # Show framework-specific info
            if [ -f "$path/artisan" ]; then
                echo -e "${MAGENTA}  Framework: Laravel${NC}"
                echo ""
                echo -e "${YELLOW}Commandes disponibles:${NC}"
                echo -e "  ${CYAN}art${NC}             - Laravel Artisan"
                echo -e "  ${CYAN}tinker${NC}          - Laravel Tinker"
                echo -e "  ${CYAN}migrate${NC}         - Run migrations"
                echo -e "  ${CYAN}pest / phpunit${NC}  - Run tests"
            elif [ -f "$path/bin/console" ]; then
                echo -e "${MAGENTA}  Framework: Symfony${NC}"
                echo ""
                echo -e "${YELLOW}Commandes disponibles:${NC}"
                echo -e "  ${CYAN}console / sf${NC}   - Symfony Console"
                echo -e "  ${CYAN}cc${NC}              - Cache clear"
                echo -e "  ${CYAN}make${NC}            - Maker bundle"
            fi

            echo ""
            echo -e "${BLUE}Helpers universels:${NC}"
            echo -e "  ${CYAN}project <name>${NC}  - Changer de projet"
            echo -e "  ${CYAN}project list${NC}    - Liste les projets"
            echo ""

            return 0
        fi
    done

    echo -e "${RED}Choix invalide${NC}"
    return 1
}

# Main menu logic
run_menu() {
    # Don't show menu if already in a project directory
    # (Avoids showing menu on every cd command)
    if [ "$WORKSPACE_MENU_SHOWN" = "1" ]; then
        return 0
    fi

    show_banner

    local projects=($(detect_projects))

    show_menu "${projects[@]}"

    if [ ${#projects[@]} -eq 0 ]; then
        export WORKSPACE_MENU_SHOWN=1
        return 0
    fi

    echo -n -e "${GREEN}Votre choix [0-${#projects[@]}]: ${NC}"
    read choice

    navigate_to_project "$choice" "${projects[@]}"

    # Mark menu as shown to avoid repetition
    export WORKSPACE_MENU_SHOWN=1
}

# Only run menu if in interactive shell
if [ -t 0 ]; then
    run_menu
fi
