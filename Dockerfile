FROM php:7.4-fpm-buster

COPY entrypoint.sh /entrypoint.sh
COPY config/ /usr/local/etc/php/config/
COPY docker.conf /usr/local/etc/php-fpm.d/docker.conf

RUN apt-get update && apt-get install --no-install-recommends -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libmcrypt-dev \
    mariadb-client \
    libicu-dev \
    libxml2-dev \
    unzip \
    libzip-dev \
    git \
    ssh \
    gnupg \
    libonig-dev \
&& rm -rf /var/lib/apt/lists/* \
&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& docker-php-ext-install iconv \
&& docker-php-ext-install pdo_mysql \
&& docker-php-ext-configure gd --with-freetype --with-jpeg \
&& docker-php-ext-install -j$(nproc) gd \
&& docker-php-ext-install mbstring \
&& docker-php-ext-install gettext \
&& docker-php-ext-install exif \
&& docker-php-ext-install intl \
&& docker-php-ext-install zip \
&& docker-php-ext-install opcache \
&& docker-php-ext-install bcmath \
&& docker-php-ext-install xmlrpc \
&& pecl install xdebug-2.9.0 \
&& docker-php-ext-enable xdebug \
&& pecl install apcu-5.1.18 \
&& docker-php-ext-enable apcu \
&& composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative  --no-interaction \
&& chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
