#!/bin/bash

# PHPModDock-Lite - Workspace Aliases (Contextual & Intelligent)
# Useful shortcuts for Laravel and Symfony development

# Colors for messages
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Helper: Detect current framework
_detect_framework() {
    if [ -f "$(pwd)/artisan" ]; then
        echo "laravel"
    elif [ -f "$(pwd)/bin/console" ]; then
        echo "symfony"
    else
        echo "unknown"
    fi
}

# Helper: Show error message
_show_error() {
    echo -e "${RED}✗ $1${NC}" >&2
    echo -e "${YELLOW}💡 $2${NC}" >&2
}

# General
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Laravel Artisan (with context check)
art() {
    if [ -f "$(pwd)/artisan" ]; then
        php artisan "$@"
    else
        _show_error "Not in a Laravel project" "Navigate to a Laravel project first: project laravel"
    fi
}

tinker() {
    if [ -f "$(pwd)/artisan" ]; then
        php artisan tinker "$@"
    else
        _show_error "Not in a Laravel project" "Navigate to a Laravel project first: project laravel"
    fi
}

migrate() {
    local framework=$(_detect_framework)
    if [ "$framework" = "laravel" ]; then
        php artisan migrate "$@"
    elif [ "$framework" = "symfony" ]; then
        php bin/console doctrine:migrations:migrate "$@"
    else
        _show_error "Not in a Laravel or Symfony project" "Navigate to a project first: project laravel / project symfony"
    fi
}

alias migrate-fresh='art migrate:fresh --seed'
alias db-seed='art db:seed'
alias cache-clear='art cache:clear'
alias config-clear='art config:clear'
alias route-clear='art route:clear'
alias view-clear='art view:clear'
alias optimize='art optimize'
alias optimize-clear='art optimize:clear'
alias queue-work='art queue:work'
alias queue-listen='art queue:listen'

# Laravel Testing (with context check)
pest() {
    if [ -f "$(pwd)/vendor/bin/pest" ]; then
        ./vendor/bin/pest "$@"
    elif [ -f "$(pwd)/artisan" ]; then
        php artisan test "$@"
    else
        _show_error "Pest not found" "Install Pest first: composer require pestphp/pest --dev"
    fi
}

phpunit() {
    if [ -f "$(pwd)/vendor/bin/phpunit" ]; then
        ./vendor/bin/phpunit "$@"
    else
        _show_error "PHPUnit not found" "Install PHPUnit first or use 'php artisan test'"
    fi
}

# Symfony Console (with context check)
console() {
    if [ -f "$(pwd)/bin/console" ]; then
        php bin/console "$@"
    else
        _show_error "Not in a Symfony project" "Navigate to a Symfony project first: project symfony"
    fi
}

sf() {
    if [ -f "$(pwd)/bin/console" ]; then
        php bin/console "$@"
    else
        _show_error "Not in a Symfony project" "Navigate to a Symfony project first: project symfony"
    fi
}

cc() {
    local framework=$(_detect_framework)
    if [ "$framework" = "laravel" ]; then
        php artisan cache:clear "$@"
    elif [ "$framework" = "symfony" ]; then
        php bin/console cache:clear "$@"
    else
        _show_error "Not in a framework project" "Navigate to a project first: project laravel / project symfony"
    fi
}

alias cw='console cache:warmup'
alias doctrine='console doctrine'

# Note: 'make' conflicts with system make command, use full path
symfony-make() {
    if [ -f "$(pwd)/bin/console" ]; then
        php bin/console make "$@"
    else
        _show_error "Not in a Symfony project" "Navigate to a Symfony project first: project symfony"
    fi
}

# Composer (universal)
alias c='composer'
alias ci='composer install'
alias cu='composer update'
alias cr='composer require'
alias cda='composer dump-autoload'
alias co='composer outdated'

# NPM / Yarn / PNPM (universal)
alias ni='npm install'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrw='npm run watch'

alias yi='yarn install'
alias yrd='yarn dev'
alias yrb='yarn build'
alias yrw='yarn watch'

alias pi='pnpm install'
alias prd='pnpm run dev'
alias prb='pnpm run build'
alias prw='pnpm run watch'

# Git (universal)
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gb='git branch'

# Docker (universal)
alias dc='docker-compose'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcr='docker-compose restart'
alias dcl='docker-compose logs -f'

# Permissions (universal)
alias fix-perms='sudo chown -R www-data:www-data /var/www'

echo "PHPModDock-Lite aliases loaded! (contextual mode)"
