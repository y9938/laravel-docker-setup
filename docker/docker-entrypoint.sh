#!/bin/sh
set -e

cd /var/www

if [ -f "artisan" ]; then
  chown -R laravel:laravel /var/www/storage /var/www/bootstrap/cache
  chmod -R 775 /var/www/storage /var/www/bootstrap/cache

  if [ ! -d "vendor" ]; then
    echo ">> Installing composer dependencies..."
    composer install --optimize-autoloader
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

  echo ">> Running seeders..."
  php artisan db:seed --force || true
else
  echo ">> Not a Laravel project"
fi

exec "$@"
