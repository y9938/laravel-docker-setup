set dotenv-load
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

APP_UID := env("APP_UID", "1000")
APP_GID := env("APP_GID", "1000")

IMAGE_NAME := "laravel-setup-php-fpm"
IMAGE_TAG  := "latest"
IMAGE      := IMAGE_NAME + ":" + IMAGE_TAG

# Show available recipes
default:
  @just --list

# Build Docker image
build:
  docker build -f docker/Dockerfile \
    --build-arg UID={{APP_UID}} \
    --build-arg GID={{APP_GID}} \
    -t {{IMAGE}} .

# Open shell in PHP-FPM container
shell:
  docker compose exec --user www php-fpm bash

# Generate API documentation
docs:
  docker compose exec --user www php-fpm php artisan scribe:generate

# Reset database with fresh migration and seeding
db:
  docker compose exec --user www php-fpm php artisan migrate:fresh --seed

# Run tests
test:
  docker compose exec --user www php-fpm php artisan test
