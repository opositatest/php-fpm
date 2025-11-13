#!/bin/bash
CONTAINER_NAME=php-fpm-test
docker run -d -it --name ${CONTAINER_NAME} -v $PWD:/var/www/html/public -e APP_ENV=dev -p 80:80 php-fpm

sleep 5
curl 'http://localhost/'
printf '\n'

docker stop ${CONTAINER_NAME}
docker rm ${CONTAINER_NAME}