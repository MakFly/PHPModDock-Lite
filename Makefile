.PHONY: help install up down restart rebuild logs shell php composer artisan console test mysql redis clean

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default profile
PROFILE ?= frankenphp

help: ## Show this help message
	@echo "$(BLUE)PHPModDock-Lite - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick Start:$(NC)"
	@echo "  make up          - Start FrankenPHP stack (recommended)"
	@echo "  make dev         - Interactive web server selection menu"
	@echo "  make workspace   - Enter development container"
	@echo ""
	@echo "$(YELLOW)Web Server Stacks:$(NC)"
	@echo "  frankenphp       - Modern PHP server (default, 3-4x faster)"
	@echo "  nginx-stack      - Traditional Nginx + PHP-FPM"
	@echo ""
	@echo "$(YELLOW)Framework Shortcuts:$(NC)"
	@echo "  make laravel     - Laravel optimized stack (FrankenPHP)"
	@echo "  make symfony     - Symfony optimized stack (FrankenPHP)"
	@echo "  make full        - All services enabled"

install: ## First time setup - copy .env and build containers
	@echo "$(GREEN)Setting up Laradock Lite...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN).env file created. Please review and update it.$(NC)"; \
	else \
		echo "$(YELLOW).env file already exists.$(NC)"; \
	fi
	@mkdir -p projects logs/nginx services/mysql/docker-entrypoint-initdb.d services/postgres/docker-entrypoint-initdb.d
	@echo "$(GREEN)Installation complete! Run 'make up' to start containers.$(NC)"

dev: ## Interactive menu to choose web server (FrankenPHP or Nginx)
	@./scripts/web-server-menu.sh

up: ## Start containers with FrankenPHP (default - recommended)
	@echo "$(GREEN)Starting FrankenPHP stack...$(NC)"
	COMPOSE_PROFILES=frankenphp docker-compose up -d frankenphp workspace mysql redis meilisearch rabbitmq mailhog adminer dozzle
	@echo "$(GREEN)FrankenPHP stack started successfully!$(NC)"
	@echo "$(YELLOW)Access points:$(NC)"
	@echo "  Application:     http://localhost"
	@echo "  Adminer:         http://localhost:8081"
	@echo "  Mailhog:         http://localhost:8025"
	@echo "  Dozzle:          http://localhost:8888"
	@echo "  RabbitMQ:        http://localhost:15672"
	@echo "  Meilisearch:     http://localhost:7700"
	@echo ""
	@echo "$(BLUE)💡 Tip: Use 'make dev' for interactive server selection$(NC)"

down: ## Stop and remove containers
	@echo "$(RED)Stopping containers...$(NC)"
	docker-compose down
	@echo "$(GREEN)Containers stopped.$(NC)"

restart: ## Restart all containers
	@echo "$(YELLOW)Restarting containers...$(NC)"
	docker-compose restart
	@echo "$(GREEN)Containers restarted.$(NC)"

rebuild: ## Rebuild containers (use SERVICE=name for specific service)
ifdef SERVICE
	@echo "$(YELLOW)Rebuilding $(SERVICE)...$(NC)"
	docker-compose build --no-cache $(SERVICE)
else
	@echo "$(YELLOW)Rebuilding all containers...$(NC)"
	docker-compose build --no-cache
endif
	@echo "$(GREEN)Rebuild complete.$(NC)"

logs: ## Show container logs (use SERVICE=name for specific service)
ifdef SERVICE
	docker-compose logs -f $(SERVICE)
else
	docker-compose logs -f
endif

shell: ## Enter workspace container
	@echo "$(GREEN)Entering workspace container...$(NC)"
	docker-compose exec workspace bash

workspace: ## Enter workspace container (alias for shell)
	@echo "$(GREEN)Entering workspace container...$(NC)"
	docker-compose exec workspace bash

php: ## Enter PHP-FPM container
	@echo "$(GREEN)Entering PHP-FPM container...$(NC)"
	docker-compose exec php-fpm bash

composer: ## Run composer command (use CMD="install" etc.)
ifdef CMD
	docker-compose exec workspace composer $(CMD)
else
	@echo "$(RED)Usage: make composer CMD=\"install\"$(NC)"
endif

artisan: ## Run Laravel artisan command (use CMD="migrate" etc.)
ifdef CMD
	docker-compose exec workspace php artisan $(CMD)
else
	@echo "$(RED)Usage: make artisan CMD=\"migrate\"$(NC)"
endif

console: ## Run Symfony console command (use CMD="cache:clear" etc.)
ifdef CMD
	docker-compose exec workspace php bin/console $(CMD)
else
	@echo "$(RED)Usage: make console CMD=\"cache:clear\"$(NC)"
endif

test: ## Run tests (PHPUnit or Pest)
	@echo "$(GREEN)Running tests...$(NC)"
	docker-compose exec workspace php artisan test || docker-compose exec workspace ./vendor/bin/phpunit

mysql: ## Enter MySQL CLI
	@echo "$(GREEN)Entering MySQL...$(NC)"
	docker-compose exec mysql mysql -uroot -proot

postgres: ## Enter PostgreSQL CLI
	@echo "$(GREEN)Entering PostgreSQL...$(NC)"
	docker-compose exec postgres psql -U default -d default

redis: ## Enter Redis CLI
	@echo "$(GREEN)Entering Redis CLI...$(NC)"
	docker-compose exec redis redis-cli

ps: ## Show running containers
	docker-compose ps

stats: ## Show container resource usage
	docker stats

clean: ## Remove all containers, volumes, and images
	@echo "$(RED)WARNING: This will remove all containers, volumes, and images!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v --rmi all; \
		echo "$(GREEN)Cleanup complete.$(NC)"; \
	else \
		echo "$(YELLOW)Cleanup cancelled.$(NC)"; \
	fi

php-switch: ## Switch PHP version (use VER=8.2)
ifdef VER
	@echo "$(YELLOW)Switching to PHP $(VER)...$(NC)"
	@sed -i 's/^PHP_VERSION=.*/PHP_VERSION=$(VER)/' .env
	docker-compose build php-fpm workspace
	docker-compose up -d php-fpm workspace
	@echo "$(GREEN)PHP version switched to $(VER)$(NC)"
else
	@echo "$(RED)Usage: make php-switch VER=8.2$(NC)"
endif

laravel: ## Start with Laravel profile (with FrankenPHP)
	@$(MAKE) up PROFILE=laravel

symfony: ## Start with Symfony profile (with FrankenPHP)
	@$(MAKE) up PROFILE=symfony

full: ## Start with all services
	@$(MAKE) up PROFILE=full

minimal: ## Start with minimal services (default with FrankenPHP)
	@$(MAKE) up PROFILE=minimal

frankenphp: ## Start with FrankenPHP only
	@$(MAKE) up PROFILE=frankenphp

nginx-stack: ## Start with PHP-FPM + Nginx instead of FrankenPHP
	@$(MAKE) up PROFILE=nginx
