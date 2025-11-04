FROM php:8.3-fpm

ARG UID
ARG GID

RUN apt-get update && apt-get install -y \
    netcat-traditional \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    git \
&& docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
&& apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY ./docker/php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf

COPY ./docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN groupadd -g $GID laravel && useradd -u $UID -g $GID -m laravel
USER laravel

WORKDIR /var/www

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
