#!/bin/bash
set -e

TIME_WAIT_FINISH="${TIME_TO_FINISH:-60}"
SCRIPT_INIT_DIR='/var/www/html/docker/init.d'
THEFILE="$PHP_INI_DIR/conf.d/cusmtom.ini"
NEW_RELIC_IGNORE='Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException,Symfony\\Component\\HttpKernel\\Exception\\AccessDeniedHttpException,Symfony\\Component\\HttpKernel\\Exception\\MethodNotAllowedHttpException'
NEW_RELIC_FILE='/usr/local/etc/php/conf.d/newrelic.ini'

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

if [[ "$NEWRELIC" = "yes" && -n "$NEW_RELIC_KEY" && -n "$NEW_RELIC_APP_NAME" && -s "$NEW_RELIC_FILE" ]]; then
    [[ ! -n "$NEWRELIC_DAEMON_ADDRESS" ]] && echo "Executing with newrelic daemon on localhost"
    sed -E -i \
        -e 's/(newrelic.license) =.*/\1 = "'$NEW_RELIC_KEY'"/' \
        -e 's/(newrelic.appname) =.*/\1 = "'$NEW_RELIC_APP_NAME'"/' \
        -e "s/;*(newrelic.error_collector.ignore_exceptions) =.*/\1 = \"$NEW_RELIC_IGNORE\"/" \
        -e 's/;*(newrelic.distributed_tracing_enabled) =.*/\1 = false/' \
        -e 's/;*(newrelic.application_logging.forwarding.context_data.enabled) =.*/\1 = true/' \
        "$NEW_RELIC_FILE"
    if [[ -n "$NEWRELIC_DAEMON_ADDRESS" ]]; then
        echo "Executing with newrelic daemon on $NEWRELIC_DAEMON_ADDRESS"
        sed -E -i \
        -e 's/;*(newrelic.daemon.address) =.*/\1 = "'${NEWRELIC_DAEMON_ADDRESS}'"/' \
        "$NEW_RELIC_FILE"
    fi
else
    echo "Removing newrelic configuration"
    [ -s "$NEW_RELIC_FILE" ] && rm "$NEW_RELIC_FILE"
fi

if [[ "$XDEBUG" = "yes" ]];
then
    echo "Executing php with xdebug"
    cp $PHP_INI_DIR/config/xdebug.ini $PHP_INI_DIR/conf.d/xdebug.ini
else
    echo "Removing xdebug in production mode"
    [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ] && rm "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"
fi

if [[ "$PHP_EXECUTION_MODE" = "command" && "$NEWRELIC" = "yes" ]];
then
    echo "Executing php in command mode"
    # Copy default config in order to start daemon
    cp /etc/newrelic/newrelic.cfg.template /etc/newrelic/newrelic.cfg
    # Start the daemon manually
    /etc/init.d/newrelic-daemon restart
    #Dummy request to connect the app to New Relic and give it a second to finish
    php -i > /dev/null
    sleep 1
fi

# Run all scripts in the init.d directory
if [[ -d $SCRIPT_INIT_DIR ]]; then
    for script in $SCRIPT_INIT_DIR/*.sh; do
        [[ -s $script ]] && "$script"
    done
fi

# First arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

echo "Executing entrypoint: $@"

if [[ "$PHP_EXECUTION_MODE" = "command" && "$NEWRELIC" = "yes" ]];
then
    # Run command
    "$@"
    # Give it some time to report data to New Relic before container shuts down
    sleep $TIME_WAIT_FINISH
else
    exec "$@"
fi
