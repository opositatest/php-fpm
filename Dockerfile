FROM php:8.1-fpm-buster

ARG XDEBUG=xdebug-3.2.0
ARG APCU=apcu-5.1.22
ARG NEWRELIC=10.3.0.315
ARG PHP_SECURITY_CHECKER=2.0.6

COPY entrypoint.sh /entrypoint.sh
COPY config/ /usr/local/etc/php/config/
COPY zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

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
    wkhtmltopdf \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && docker-php-ext-install iconv pdo_mysql mbstring gettext exif intl zip opcache bcmath xml soap \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install ${XDEBUG} ${APCU} \
    && docker-php-ext-enable xdebug apcu \
    && chmod 755 /entrypoint.sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://download.newrelic.com/php_agent/archive/${NEWRELIC}/newrelic-php5-${NEWRELIC}-linux.tar.gz | \
    tar -C /tmp -zx && \
    export NR_INSTALL_USE_CP_NOT_LN=1 && \
    export NR_INSTALL_SILENT=1 && \
    /tmp/newrelic-php5-*/newrelic-install install && \
    chown www-data:www-data -R /var/log/newrelic/ && \
    rm -rf /tmp/newrelic-php5-* /tmp/nrinstall* && \
    curl -sL "https://github.com/fabpot/local-php-security-checker/releases/download/v${PHP_SECURITY_CHECKER}/local-php-security-checker_${PHP_SECURITY_CHECKER}_linux_amd64" \
        -o /usr/local/bin/php-security-checker && \
    chmod +x /usr/local/bin/php-security-checker

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
