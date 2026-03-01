# Laravel Docker Setup

- PHP-FPM, NGINX, MySQL, phpMyAdmin (in `compose.yaml`)

## Run a container

```bash
cp .env.example .env
# !change .env for yourself
docker compose up -d php-fpm
docker compose exec --user www php-fpm bash
# or `just shell`
```

## Create a project:

**_Rewrite below for yourself:_**

*RECOMENDED:*

**The latest version** via [laravel/installer package](https://packagist.org/packages/laravel/installer)

```bash
composer global require laravel/installer && \
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Check options via `laravel new -h`
laravel new example-app

# copy your `.env` content to `example-app/.env`
mv example-app/* example-app/.* ./
rmdir example-app
```

*OR:*

**The specific version** via composer

```bash
composer create-project --prefer-dist laravel/laravel example-app ^11.0

# copy your `.env` content to `example-app/.env`
mv example-app/* example-app/.* ./
rmdir example-app
```

## Quick Actions

```bash
just
```
