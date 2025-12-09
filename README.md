# Laravel Docker Setup

- NGINX, MySQL, phpMyAdmin

## Создание проекта:

```bash
cp .env.example .env
# !change .env for yourself
./run.sh build
docker compose up -d php-fpm
docker compose exec php-fpm bash
```

```bash
composer global require laravel/installer

export PATH="$HOME/.composer/vendor/bin:$PATH"

laravel new example-app

mv example-app/* example-app/.* ./
rmdir example-app
```
