# Laravel Docker Setup

- NGINX, MySQL, phpMyAdmin

## Создание проекта:

```bash
touch .env
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

Изменить в `.env`

```
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=app
DB_USERNAME=laravel
DB_PASSWORD=secret
DB_ROOT_PASSWORD=secret
```
