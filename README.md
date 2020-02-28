Opositatest php-fpm
---

Install
---
Build image:
> docker built . -t [REPOSITORY:TAG]

Run image:
> docker run -e APP_ENV=dev --name [NAME_CONTAINER] opositatest/php-fpm:latest 

Test service php-fpm through Nginx:
> docker-compose -f docker-compose.test.yml up

Environment in .env:
* APP_ENV=(dev|prod)

ARG in DockerFiles: 
* XDEBUG=xdebug-X.X.X
* APCU=apcu-X.X.X