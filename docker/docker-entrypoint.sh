#!/bin/sh
set -e

APP_ENV=${APP_ENV:-unknown}
echo ">> Running in $APP_ENV mode"

# Only for Laravel project
if [ -f "artisan" ]; then

  echo ">> Ensuring composer dependencies are up to date..."
  if [ "$APP_ENV" = "production" ]; then
    composer install --no-dev --optimize-autoloader
  else
    composer install --optimize-autoloader
  fi

  if [ -f ".env" ] && grep -q '^APP_KEY=$' .env; then
    echo ">> Generating application key..."
    php artisan key:generate --ansi
  fi

  echo ">> Waiting for MySQL..."
  while ! nc -z mysql 3306; do sleep 1; done

  echo ">> Running migrations..."
  php artisan migrate --force || true

  if [ ! -L "public/storage" ] && [ -d "storage/app/public" ]; then
    echo ">> Creating storage link..."
    php artisan storage:link
  fi

  if [ "$APP_ENV" = "local" ]; then
    echo ">> Running seeders..."
    php artisan db:seed --force || true

    if composer show knuckleswtf/scribe > /dev/null 2>&1; then
      echo ">> Generating API documentation..."
      php artisan scribe:generate --no-interaction || echo ">> Documentation generation failed, continuing..."
    else
      echo ">> Scribe not installed, skipping documentation generation"
    fi
  fi

  if [ "$APP_ENV" = "production" ]; then
    php artisan optimize
  fi
else
  echo ">> Not a Laravel project"
fi

exec "$@"
