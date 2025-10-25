#!/usr/bin/env bash

# PHPModDock-Lite - /etc/hosts Manager
# Gestion intelligente multi-OS du fichier hosts

set -e

# Load OS detection library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/os-detection.sh"

# Colors (si pas déjà définis)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
CYAN=${CYAN:-'\033[0;36m'}
NC=${NC:-'\033[0m'}

# Marker for PHPModDock-Lite entries
MARKER_START="# BEGIN PHPModDock-Lite - Auto-generated"
MARKER_END="# END PHPModDock-Lite"

# Get hosts file path
HOSTS_FILE=$(get_hosts_file_path)

# Functions
print_header() {
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  PHPModDock-Lite - Hosts Manager${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
}

# Check if entry exists in hosts file
entry_exists() {
    local domain=$1
    local hosts_file=${2:-$HOSTS_FILE}

    if [ ! -f "$hosts_file" ]; then
        return 1
    fi

    grep -q "^127.0.0.1[[:space:]]\+$domain" "$hosts_file" 2>/dev/null
}

# Add entry to hosts file
add_entry() {
    local domain=$1
    local ip=${2:-127.0.0.1}
    local comment=${3:-""}

    # Check if already exists
    if entry_exists "$domain"; then
        echo -e "${YELLOW}⚠ L'entrée existe déjà: $domain${NC}"
        return 0
    fi

    # Prepare entry
    local entry="$ip\t$domain"
    if [ -n "$comment" ]; then
        entry="$entry\t# $comment"
    fi

    # Add entry based on OS
    local os_type=$(detect_os | cut -d':' -f1)

    if ! check_admin_privileges; then
        echo -e "${RED}✗ Privilèges administrateur requis${NC}"
        echo ""
        show_admin_instructions "$@"
        return 1
    fi

    # Backup first
    backup_hosts_file || {
        echo -e "${YELLOW}⚠ Backup échoué, continuer quand même ? [y/N]${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            return 1
        fi
    }

    # Add entry
    case "$os_type" in
        linux|macos)
            echo -e "$entry" | sudo tee -a "$HOSTS_FILE" > /dev/null
            ;;
        wsl|windows)
            echo -e "$entry" >> "$HOSTS_FILE"
            ;;
    esac

    echo -e "${GREEN}✓ Ajouté: $domain → $ip${NC}"
    return 0
}

# Remove entry from hosts file
remove_entry() {
    local domain=$1

    if ! entry_exists "$domain"; then
        echo -e "${YELLOW}⚠ L'entrée n'existe pas: $domain${NC}"
        return 0
    fi

    if ! check_admin_privileges; then
        echo -e "${RED}✗ Privilèges administrateur requis${NC}"
        echo ""
        show_admin_instructions "$@"
        return 1
    fi

    # Backup first
    backup_hosts_file

    # Remove entry based on OS
    local os_type=$(detect_os | cut -d':' -f1)
    local temp_file="/tmp/hosts.tmp.$$"

    case "$os_type" in
        linux|macos)
            grep -v "^127.0.0.1[[:space:]]\+$domain" "$HOSTS_FILE" | sudo tee "$temp_file" > /dev/null
            sudo mv "$temp_file" "$HOSTS_FILE"
            ;;
        wsl|windows)
            grep -v "^127.0.0.1[[:space:]]\+$domain" "$HOSTS_FILE" > "$temp_file"
            mv "$temp_file" "$HOSTS_FILE"
            ;;
    esac

    echo -e "${GREEN}✓ Supprimé: $domain${NC}"
    return 0
}

# Add multiple entries with markers
add_managed_entries() {
    local -a entries=("$@")

    if ! check_admin_privileges; then
        echo -e "${RED}✗ Privilèges administrateur requis${NC}"
        echo ""
        show_admin_instructions "$@"
        return 1
    fi

    # Backup first
    backup_hosts_file

    # Remove existing managed section
    remove_managed_entries_silent

    # Prepare new managed section
    local managed_content="$MARKER_START\n"

    for entry in "${entries[@]}"; do
        local domain=$(echo "$entry" | cut -d':' -f1)
        local ip=$(echo "$entry" | cut -d':' -f2)
        local comment=$(echo "$entry" | cut -d':' -f3)

        if [ -z "$ip" ]; then
            ip="127.0.0.1"
        fi

        managed_content+="$ip\t$domain"
        if [ -n "$comment" ]; then
            managed_content+="\t# $comment"
        fi
        managed_content+="\n"

        echo -e "${GREEN}✓ Ajout de: $domain → $ip${NC}"
    done

    managed_content+="$MARKER_END\n"

    # Add managed section based on OS
    local os_type=$(detect_os | cut -d':' -f1)

    case "$os_type" in
        linux|macos)
            echo -e "$managed_content" | sudo tee -a "$HOSTS_FILE" > /dev/null
            ;;
        wsl|windows)
            echo -e "$managed_content" >> "$HOSTS_FILE"
            ;;
    esac

    echo -e "${GREEN}✓ Section PHPModDock-Lite ajoutée${NC}"
    return 0
}

# Remove managed entries (silent version without messages)
remove_managed_entries_silent() {
    if ! grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
        return 0
    fi

    local os_type=$(detect_os | cut -d':' -f1)
    local temp_file="/tmp/hosts.tmp.$$"

    # Remove lines between markers
    case "$os_type" in
        linux|macos)
            sed "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE" | sudo tee "$temp_file" > /dev/null
            sudo mv "$temp_file" "$HOSTS_FILE"
            ;;
        wsl|windows)
            sed "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE" > "$temp_file"
            mv "$temp_file" "$HOSTS_FILE"
            ;;
    esac
}

# Remove managed entries
remove_managed_entries() {
    if ! grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Aucune entrée PHPModDock-Lite trouvée${NC}"
        return 0
    fi

    if ! check_admin_privileges; then
        echo -e "${RED}✗ Privilèges administrateur requis${NC}"
        echo ""
        show_admin_instructions "$@"
        return 1
    fi

    # Backup first
    backup_hosts_file

    remove_managed_entries_silent

    echo -e "${GREEN}✓ Entrées PHPModDock-Lite supprimées${NC}"
    return 0
}

# List Laradock entries
list_entries() {
    echo -e "${BLUE}Entrées PHPModDock-Lite dans $HOSTS_FILE:${NC}"
    echo ""

    if ! grep -q "$MARKER_START" "$HOSTS_FILE" 2>/dev/null; then
        echo -e "${YELLOW}Aucune entrée gérée trouvée${NC}"
        echo ""
        echo -e "${BLUE}Toutes les entrées locales (127.0.0.1):${NC}"
        grep "^127.0.0.1" "$HOSTS_FILE" 2>/dev/null | grep -v "^127.0.0.1[[:space:]]\+localhost" || echo "Aucune"
        return 0
    fi

    # Extract managed section
    sed -n "/$MARKER_START/,/$MARKER_END/p" "$HOSTS_FILE" | grep -v "^#"

    echo ""
}

# Show help
show_help() {
    cat << EOF
${BLUE}PHPModDock-Lite - Hosts Manager${NC}

${YELLOW}Usage:${NC}
  $0 [command] [options]

${YELLOW}Commandes:${NC}
  ${GREEN}add <domain> [ip] [comment]${NC}
      Ajoute une entrée au fichier hosts
      Exemples:
        $0 add myapp.localhost
        $0 add myapp.localhost 127.0.0.1 "Mon application"

  ${GREEN}remove <domain>${NC}
      Supprime une entrée du fichier hosts
      Exemple:
        $0 remove myapp.localhost

  ${GREEN}add-managed <entries>${NC}
      Ajoute plusieurs entrées dans une section gérée
      Format: domain:ip:comment (ip et comment optionnels)
      Exemples:
        $0 add-managed "laravel-app.localhost::Laravel" "symfony-api.localhost::Symfony"

  ${GREEN}remove-managed${NC}
      Supprime toutes les entrées de la section PHPModDock-Lite

  ${GREEN}list${NC}
      Liste toutes les entrées PHPModDock-Lite

  ${GREEN}check <domain>${NC}
      Vérifie si une entrée existe
      Exemple:
        $0 check laravel-app.localhost

  ${GREEN}info${NC}
      Affiche les informations sur l'OS et le fichier hosts

  ${GREEN}help${NC}
      Affiche cette aide

${YELLOW}Exemples d'utilisation:${NC}

  # Ajouter Laravel et Symfony
  $0 add-managed "laravel-app.localhost::Laravel Project" "symfony-api.localhost::Symfony API"

  # Vérifier si une entrée existe
  $0 check laravel-app.localhost

  # Lister toutes les entrées gérées
  $0 list

  # Supprimer une entrée spécifique
  $0 remove symfony-api.localhost

${YELLOW}Notes:${NC}
  - Privilèges administrateur requis pour modifier le fichier hosts
  - Linux/macOS: Utilisez 'sudo' pour exécuter le script
  - Windows: Lancez Git Bash/PowerShell en tant qu'Administrateur
  - WSL: Peut nécessiter sudo ou modification manuelle via Windows

EOF
}

# Main
main() {
    local command=${1:-help}

    case "$command" in
        add)
            print_header
            print_os_info
            echo ""
            add_entry "${2}" "${3}" "${4}"
            ;;

        remove)
            print_header
            print_os_info
            echo ""
            if [ -z "$2" ]; then
                echo -e "${RED}✗ Domaine requis${NC}"
                echo "Usage: $0 remove <domain>"
                exit 1
            fi
            remove_entry "$2"
            ;;

        add-managed)
            print_header
            print_os_info
            echo ""
            shift
            add_managed_entries "$@"
            ;;

        remove-managed)
            print_header
            print_os_info
            echo ""
            remove_managed_entries
            ;;

        list)
            print_header
            list_entries
            ;;

        check)
            if [ -z "$2" ]; then
                echo -e "${RED}✗ Domaine requis${NC}"
                echo "Usage: $0 check <domain>"
                exit 1
            fi

            if entry_exists "$2"; then
                echo -e "${GREEN}✓ L'entrée existe: $2${NC}"
                grep "^127.0.0.1[[:space:]]\+$2" "$HOSTS_FILE"
                exit 0
            else
                echo -e "${YELLOW}✗ L'entrée n'existe pas: $2${NC}"
                exit 1
            fi
            ;;

        info)
            print_header
            print_os_info
            echo ""
            echo -e "${BLUE}Chemin du fichier hosts:${NC} $HOSTS_FILE"
            if [ -f "$HOSTS_FILE" ]; then
                echo -e "${GREEN}✓ Fichier existe${NC}"
                if [ -r "$HOSTS_FILE" ]; then
                    echo -e "${GREEN}✓ Lecture autorisée${NC}"
                fi
                if [ -w "$HOSTS_FILE" ]; then
                    echo -e "${GREEN}✓ Écriture autorisée${NC}"
                else
                    echo -e "${YELLOW}✗ Écriture non autorisée (privilèges requis)${NC}"
                fi
            else
                echo -e "${RED}✗ Fichier introuvable${NC}"
            fi
            ;;

        help|--help|-h)
            show_help
            ;;

        *)
            echo -e "${RED}✗ Commande inconnue: $command${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
