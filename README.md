![Github Actions](https://github.com/opositatest/php-fpm/actions/workflows/test.yml/badge.svg)

Opositatest php-fpm
---

Install
---
Build image:
> docker built . -t [REPOSITORY:TAG]

Run image:
> docker run --rm -e APP_ENV=dev -v php_unix_socket:/run/php/ --name [NAME_CONTAINER] [REPOSITORY:TAG] 

Test service php-fpm through Nginx:
> docker compose -f docker-compose.test.yml up

When finished, remember to go down with:
> docker compose -f docker-compose.test.yml down

Environment in .env:
* APP_ENV=(dev|prod)
* NEWRELIC=(yes|no)
* NEW_RELIC_KEY=(your_key)
* NEW_RELIC_APP_NAME=test-php-fpm
* NEWRELIC_DAEMON_ADDRESS=url:port

ARG in DockerFiles: 
* XDEBUG=xdebug-X.X.X
* APCU=apcu-X.X.X
* NEWRELIC=X.X.X.X