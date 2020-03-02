FROM php:7.4-fpm-buster

ARG XDEBUG=xdebug-2.9.2
ARG APCU=apcu-5.1.18
ARG NEWRELIC=9.7.0.258

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
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && docker-php-ext-install iconv pdo_mysql mbstring gettext exif intl zip opcache bcmath xmlrpc \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install ${XDEBUG} ${APCU} \
    && docker-php-ext-enable xdebug apcu \
    && composer global require "hirak/prestissimo:^0.3" \
        --prefer-dist --no-progress --no-suggest --optimize-autoloader --classmap-authoritative  --no-interaction \
    && chmod 755 /entrypoint.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://download.newrelic.com/php_agent/archive/${NEWRELIC}/newrelic-php5-${NEWRELIC}-linux.tar.gz | \
    tar -C /tmp -zx && \
    export NR_INSTALL_USE_CP_NOT_LN=1 && \
    export NR_INSTALL_SILENT=1 && \
    /tmp/newrelic-php5-*/newrelic-install install && \
    rm -rf /tmp/newrelic-php5-* /tmp/nrinstall*

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]