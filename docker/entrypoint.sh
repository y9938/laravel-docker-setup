#!/bin/sh
set -e

echo ">> Running dev setup..."

# Only for Laravel project
if [ ! -f "artisan" ]; then
  echo ">> Not a Laravel project"
  exec "$@"
fi

gosu www mkdir -p .hashes

if [ ! -f "vendor/autoload.php" ] || [ ! -f .hashes/.composer-hash ] || ! sha1sum -c .hashes/.composer-hash; then
  echo ">> composer.json or composer.lock changed, installing dependencies..."
  gosu www composer install --optimize-autoloader --no-interaction
  gosu www sha1sum composer.json composer.lock > .hashes/.composer-hash
  chown www: .hashes/.composer-hash
else
  echo ">> Composer dependencies up to date (hash match), skipping install."
fi

if [ -f ".env" ] && grep -q '^APP_KEY=$' .env; then
  echo ">> Generating application key..."
  gosu www php artisan key:generate --ansi
fi

if [ -f ".env.testing" ] && grep -q '^APP_KEY=$' .env.testing; then
  echo ">> Generating application key for .env.testing..."
  gosu www php artisan key:generate --env=testing --ansi
fi

echo ">> Waiting for MySQL..."
while ! nc -z mysql 3306; do sleep 1; done

echo ">> Running migrations with seed..."
set +e
MIGRATE_OUTPUT="$(gosu www php artisan migrate --seed --force 2>&1)"
MIGRATE_EXIT=$?
set -e

echo "$MIGRATE_OUTPUT"

if [ "$MIGRATE_EXIT" -ne 0 ]; then
  if echo "$MIGRATE_OUTPUT" | grep -Eq 'SQLSTATE\[|Illuminate\\Database\\QueryException'; then
    echo ">> SQL migration error detected, running migrate:fresh --seed..."
    gosu www php artisan migrate:fresh --seed
  else
    echo ">> Migration failed with non-SQL error, exiting..."
    exit "$MIGRATE_EXIT"
  fi
fi

if [ ! -L "public/storage" ] && [ -d "storage/app/public" ]; then
  echo ">> Creating storage link..."
  gosu www php artisan storage:link
fi

if composer show knuckleswtf/scribe >/dev/null 2>&1; then
  # Define all directories/files Scribe cares about
  SCRIBE_SOURCES="config/scribe.php routes/ app/Http/Controllers/ app/Http/Requests/ app/Models/"

  # Create combined hash of all .php files in those paths
  CURRENT_HASH=$(find $SCRIBE_SOURCES -type f -name "*.php" -exec sha1sum {} + | sha1sum)

  if [ ! -f .hashes/.scribe-hash ] || [ "$CURRENT_HASH" != "$(cat .hashes/.scribe-hash)" ]; then
    echo ">> Generating API documentation..."
    gosu www php artisan scribe:generate --no-interaction \
      || echo ">> Warning: Scribe generation failed, continuing..."
    echo "$CURRENT_HASH" > .hashes/.scribe-hash
    chown www: .hashes/.scribe-hash
  else
    echo ">> API docs up to date, skipping Scribe generation."
  fi
else
  echo ">> Scribe not installed, skipping API docs generation"
fi

exec "$@"
