.PHONY: help install up down start stop restart logs cli artisan migrate queue-work queue-listen queue-restart test tinker composer npm npm-run dev prod

# Help
help:
	@echo "Job Applier Laravel Project - Makefile Commands"
	@echo ""
	@echo "Installation:"
	@echo "  make install         Install PHP and JS dependencies"
	@echo ""
	@echo "Docker Compose:"
	@echo "  make up              Start all services"
	@echo "  make down            Stop and remove all services"
	@echo "  make start           Start existing containers"
	@echo "  make stop            Stop running containers"
	@echo "  make restart         Restart all services"
	@echo ""
	@echo "Application:"
	@echo "  make logs            View application logs"
	@echo "  make cli             Open shell in app container"
	@echo "  make artisan         Run Laravel Artisan command"
	@echo ""
	@echo "Database:"
	@echo "  make migrate         Run database migrations"
	@echo "  make migrate-fresh   Drop all tables and re-run migrations"
	@echo "  make seed            Run database seeders"
	@echo "  make migrate-seed    Run migrations and seeders"
	@echo ""
	@echo "Queues:"
	@echo "  make queue-work      Start queue worker (processes jobs once)"
	@echo "  make queue-listen    Start queue listener (long-running)"
	@echo "  make queue-restart   Restart queue workers"
	@echo "  make queue-retry     Retry failed jobs"
	@echo "  make queue-flush     Flush (delete) failed jobs"
	@echo ""
	@echo "Development:"
	@echo "  make test            Run PHPUnit tests"
	@echo "  make tinker          Laravel Tinker REPL"
	@echo "  make composer        Run Composer command"
	@echo "  make npm             Run NPM command"
	@echo "  make npm-run         Run NPM script"
	@echo "  make dev             Start Vite development server"
	@echo "  make prod            Build for production"
	@echo ""

# Installation
install:
	@echo "Installing dependencies..."
	docker-compose run --rm composer install
	docker-compose run --rm npm install

# Docker Compose
up:
	docker-compose up -d

down:
	docker-compose down

start:
	docker-compose start

stop:
	docker-compose stop

restart:
	docker-compose restart

logs:
	docker-compose logs -f app

cli:
	docker-compose exec app bash

# Artisan
artisan:
	docker-compose exec app php artisan $(filter-out $@,$(MAKECMDGOALS))

# Database
migrate:
	docker-compose exec app php artisan migrate

migrate-fresh:
	docker-compose exec app php artisan migrate:fresh

seed:
	docker-compose exec app php artisan db:seed

migrate-seed:
	docker-compose exec app php artisan migrate --seed

# Queues
queue-work:
	docker-compose exec app php artisan queue:work --verbose

queue-listen:
	docker-compose exec app php artisan queue:listen --verbose

queue-restart:
	docker-compose exec app php artisan queue:restart

queue-retry:
	docker-compose exec app php artisan queue:retry $(filter-out $@,$(MAKECMDGOALS))

queue-flush:
	docker-compose exec app php artisan queue:flush

# Development
test:
	docker-compose exec app php artisan test

tinker:
	docker-compose exec app php artisan tinker

composer:
	docker-compose run --rm composer $(filter-out $@,$(MAKECMDGOALS))

npm:
	docker-compose run --rm npm $(filter-out $@,$(MAKECMDGOALS))

npm-run:
	docker-compose run --rm npm run $(filter-out $@,$(MAKECMDGOALS))

dev:
	docker-compose run --rm npm run dev

prod:
	docker-compose run --rm npm run production

# Default target
default: help