ARG PHP_VERSION=8.3-fpm
FROM php:${PHP_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpng-dev libonig-dev libxml2-dev libzip-dev \
    zip unzip git \
    netcat-traditional \
&& docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

COPY --chown=www-data:www-data ./docker/docker-entrypoint.sh /usr/local/bin/
COPY ./docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data
WORKDIR /var/www

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
