#!/bin/sh
set -e

cd /var/www

echo ">> Running in ${APP_ENV:-unknown} mode"

if [ -f "artisan" ]; then
  chown -R laravel:laravel storage bootstrap/cache
  chmod -R 775 storage bootstrap/cache

  if [ ! -d "vendor" ]; then
    echo ">> Installing composer dependencies..."
    if [ "$APP_ENV" = "production" ]; then
      composer install --no-dev --optimize-autoloader
    else
      composer install --optimize-autoloader
    fi
  else
    echo ">> Vendor directory exists, skipping installation"
  fi

  if [ -f ".env" ] && grep -q '^APP_KEY=$' .env; then
    echo ">> APP_KEY is missing. Generating application key..."
    php artisan key:generate --ansi
  fi

  echo ">> Waiting for MySQL to be ready..."
  while ! nc -z mysql 3306; do
    sleep 1
  done
  echo ">> MySQL is ready!"

  echo ">> Running migrations..."
  php artisan migrate --force || true

  if [ ! -L "public/storage" ] && [ -d "storage/app/public" ]; then
    echo ">> Creating storage link..."
    php artisan storage:link
  else
    echo ">> Storage link already exists or storage directory missing"
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
