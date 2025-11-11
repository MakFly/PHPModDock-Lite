#!/usr/bin/env bash

# PHPModDock-Lite - OS Detection Library
# Détecte automatiquement l'OS et fournit les chemins appropriés

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect Operating System
detect_os() {
    local os_name=""
    local os_type=""

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"

        # Detect Linux distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            os_name="$NAME"
        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            os_name="$DISTRIB_ID"
        else
            os_name="Linux"
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
        os_name="macOS $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"

    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        os_type="windows"

        # Detect if running in WSL
        if grep -qi microsoft /proc/version 2>/dev/null; then
            os_type="wsl"
            os_name="WSL (Windows Subsystem for Linux)"
        else
            os_name="Windows"
        fi

    else
        os_type="unknown"
        os_name="Unknown OS: $OSTYPE"
    fi

    echo "$os_type:$os_name"
}

# Get hosts file path based on OS
get_hosts_file_path() {
    local os_type=$(detect_os | cut -d':' -f1)

    case "$os_type" in
        linux|macos)
            echo "/etc/hosts"
            ;;
        wsl)
            # WSL can access Windows hosts file
            echo "/mnt/c/Windows/System32/drivers/etc/hosts"
            ;;
        windows)
            # Git Bash / MSYS / Cygwin on Windows
            echo "C:/Windows/System32/drivers/etc/hosts"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if running with admin/sudo privileges
check_admin_privileges() {
    local os_type=$(detect_os | cut -d':' -f1)

    case "$os_type" in
        linux|macos)
            if [ "$EUID" -eq 0 ]; then
                return 0  # Running as root
            else
                return 1  # Not root
            fi
            ;;
        wsl)
            # WSL needs to modify Windows hosts file
            # Check if we can write to Windows hosts file
            local hosts_file=$(get_hosts_file_path)
            if [ -w "$hosts_file" ]; then
                return 0
            else
                return 1
            fi
            ;;
        windows)
            # Check if running as Administrator on Windows
            # This is tricky in Git Bash, try to write to hosts file
            local hosts_file=$(get_hosts_file_path)
            if [ -w "$hosts_file" ]; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Get command to run as admin
get_admin_command() {
    local os_type=$(detect_os | cut -d':' -f1)

    case "$os_type" in
        linux)
            echo "sudo"
            ;;
        macos)
            echo "sudo"
            ;;
        wsl)
            # On WSL, we might need to run PowerShell as admin
            echo "sudo"
            ;;
        windows)
            # On Windows, need to run as Administrator
            echo "runas /user:Administrator"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Show OS-specific instructions for admin privileges
show_admin_instructions() {
    local os_type=$(detect_os | cut -d':' -f1)
    local os_name=$(detect_os | cut -d':' -f2)

    echo -e "${YELLOW}⚠ Privilèges administrateur requis${NC}"
    echo ""

    case "$os_type" in
        linux)
            echo -e "${BLUE}Sur Linux:${NC}"
            echo "  Relancez le script avec sudo:"
            echo -e "  ${GREEN}sudo $0 $@${NC}"
            ;;
        macos)
            echo -e "${BLUE}Sur macOS:${NC}"
            echo "  Relancez le script avec sudo:"
            echo -e "  ${GREEN}sudo $0 $@${NC}"
            echo ""
            echo "  Votre mot de passe macOS vous sera demandé."
            ;;
        wsl)
            echo -e "${BLUE}Sur WSL (Windows Subsystem for Linux):${NC}"
            echo "  Option 1: Relancez avec sudo (si WSL a les droits):"
            echo -e "  ${GREEN}sudo $0 $@${NC}"
            echo ""
            echo "  Option 2: Ouvrez PowerShell en tant qu'Administrateur et modifiez:"
            echo -e "  ${CYAN}C:\\Windows\\System32\\drivers\\etc\\hosts${NC}"
            ;;
        windows)
            echo -e "${BLUE}Sur Windows:${NC}"
            echo "  Option 1: Lancez Git Bash en tant qu'Administrateur:"
            echo "    - Clic droit sur Git Bash → Exécuter en tant qu'administrateur"
            echo -e "    - Puis relancez: ${GREEN}$0 $@${NC}"
            echo ""
            echo "  Option 2: Modifiez manuellement le fichier hosts:"
            echo "    - Ouvrez Notepad en tant qu'Administrateur"
            echo -e "    - Ouvrez: ${CYAN}C:\\Windows\\System32\\drivers\\etc\\hosts${NC}"
            ;;
        *)
            echo -e "${RED}OS non supporté: $os_name${NC}"
            ;;
    esac
}

# Get line ending based on OS
get_line_ending() {
    local os_type=$(detect_os | cut -d':' -f1)

    case "$os_type" in
        windows|wsl)
            echo "\\r\\n"  # CRLF for Windows
            ;;
        *)
            echo "\\n"     # LF for Unix
            ;;
    esac
}

# Backup hosts file (OS-aware)
backup_hosts_file() {
    local hosts_file=$(get_hosts_file_path)
    local backup_file="${hosts_file}.phpmoddock-backup-$(date +%Y%m%d-%H%M%S)"
    local os_type=$(detect_os | cut -d':' -f1)

    if [ ! -f "$hosts_file" ]; then
        echo -e "${RED}✗ Fichier hosts introuvable: $hosts_file${NC}"
        return 1
    fi

    # Backup with appropriate privileges
    case "$os_type" in
        linux|macos)
            if check_admin_privileges; then
                cp "$hosts_file" "$backup_file"
            else
                sudo cp "$hosts_file" "$backup_file"
            fi
            ;;
        wsl|windows)
            cp "$hosts_file" "$backup_file" 2>/dev/null || {
                echo -e "${RED}✗ Impossible de créer un backup${NC}"
                return 1
            }
            ;;
    esac

    echo -e "${GREEN}✓ Backup créé: $backup_file${NC}"
    return 0
}

# Print OS detection info
print_os_info() {
    local os_info=$(detect_os)
    local os_type=$(echo "$os_info" | cut -d':' -f1)
    local os_name=$(echo "$os_info" | cut -d':' -f2)
    local hosts_file=$(get_hosts_file_path)

    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  OS Detection${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}Type:${NC}        $os_type"
    echo -e "${BLUE}Nom:${NC}         $os_name"
    echo -e "${BLUE}Hosts file:${NC}  $hosts_file"

    if check_admin_privileges; then
        echo -e "${BLUE}Privilèges:${NC}  ${GREEN}✓ Admin/Sudo${NC}"
    else
        echo -e "${BLUE}Privilèges:${NC}  ${YELLOW}✗ Utilisateur standard${NC}"
    fi

    echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

# Export functions for use in other scripts
export -f detect_os
export -f get_hosts_file_path
export -f check_admin_privileges
export -f get_admin_command
export -f show_admin_instructions
export -f get_line_ending
export -f backup_hosts_file
export -f print_os_info
