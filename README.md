# Laravel Docker Setup

- NGINX, MySQL, phpMyAdmin

## Create a project:

```bash
cp .env.example .env
# !change .env for yourself
docker compose up -d php-fpm
docker compose exec php-fpm bash
# or `make shell`
```

Rewrite below for yourself:

```bash
composer global require laravel/installer

export PATH="$HOME/.composer/vendor/bin:$PATH"

laravel new example-app

mv example-app/* example-app/.* ./
rmdir example-app
```

## Quick Actions

```bash
make help
```
