#!/bin/bash
set -e


THEFILE="$PHP_INI_DIR/conf.d/cusmtom.ini"
NEW_RELIC_IGNORE='Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException,Symfony\\Component\\HttpKernel\\Exception\\AccessDeniedHttpException,Symfony\\Component\\HttpKernel\\Exception\\MethodNotAllowedHttpException'

[ -f "$THEFILE" ] && rm "$THEFILE"

echo "Executing app in mode $APP_ENV"

if [[ "$APP_ENV" = "dev" ]];
then
    cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
    cp $PHP_INI_DIR/config/php-dev.ini $PHP_INI_DIR/conf.d/cusmtom.ini
else
    cp $PHP_INI_DIR/config/php-prod.ini $PHP_INI_DIR/conf.d/cusmtom.ini
    cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
fi

if [[ "$NEWRELIC" = "yes" ]];
then
    echo "Executing with newrelic daemon"
    if [[ -n $NEW_RELIC_KEY && -n $NEW_RELIC_APP_NAME ]]; then
        sed -E -i \
            -e 's/(newrelic.license) =.*/\1 = "'$NEW_RELIC_KEY'"/' \
            -e 's/(newrelic.appname) =.*/\1 = "'$NEW_RELIC_APP_NAME'"/' \
            -e "s/;*(newrelic.error_collector.ignore_exceptions) =.*/\1 = \"$NEW_RELIC_IGNORE\"/" \
            -e 's/;*(newrelic.distributed_tracing_enabled) =.*/\1 = false/' \
            /usr/local/etc/php/conf.d/newrelic.ini
    fi    
else
    echo "Removing newrelic configuration"
    [ -f "/usr/local/etc/php/conf.d/newrelic.ini" ] && rm "/usr/local/etc/php/conf.d/newrelic.ini"
fi

if [[ "$XDEBUG" = "yes" ]];
then
    echo "Executing php with xdebug"
    cp $PHP_INI_DIR/config/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini
else
    echo "Removing xdebug in production mode"
    [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ] && rm "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
fi

[[ -f /var/www/html/docker/run_hooks.sh ]] && /var/www/html/docker/run_hooks.sh

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

echo "Executing entrypoint: $@"


exec "$@"
