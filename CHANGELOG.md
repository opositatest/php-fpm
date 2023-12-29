Changelog php-fpm version 8.x

* v3.16
	* Add Dummy request to connect the app to New Relic
	
* v3.15
	* Start newrelic daemon on command execution mode

* v3.14
	* Add execution mode "command"

* v3.13
	* Add amqp php extension

* v3.12
	* Update xdebug	client host

* v3.11
	* Change config paramter xdebug.start_with_request to trigger

* v3.10
	* Update PHP to 8.2.12
	* Update newrelic to 10.14.0.3
	* Update apcu to 5.1.23

* v3.9
	* Update to PHP 8.2.7
	* Update newrelic to 10.11.0.3
	* Update xdebug to 3.2.2

* v3.8
	* Update to PHP 8.2.5
	* Update newrelic to 10.9.0.324

* v3.7
	* Added support for PostgreSQL
	
* v3.6
	* Update to PHP 8.1.14
	* Update newrelic to 10.5.0.317, performance issues

* v3.5
	* Update to PHP 8.1.13

* v3.4
	* Update dependencies

* v3.3
	* Added a handler to run all scripts in init.d folder before running the php-fpm service
	* Migrated Xdebug setting from v2 to v3

* v3.2
	* Update php and dependencies

* v3.1
	* Disable distrbuted tracing in New Relic

* v3.0
	* Upgrade to php-fpm 8.1.x

* v2.0
	* Change connection to unix socket

* v1.10
	* Move to github workflows

* v1.9
	* Add run hooks script exec

* v1.8
	* Add php-security-checker to base image

* v1.7
	* Remove access_log output

* v1.6
	* New optimize config to php-fpm (Up max children, spare and min spare )

* v1.5
	* Update xdebug-3.0.3, apcu-5.1.20, 9.16.0.295

* v1.4
	* Enable newrelic distributed_tracing_enabled

* v1.3
	* Log limit php-fpm log_limit = 8192 

* v1.2
	* Exclude exception NotFoundHttpException, AccessDeniedHttpException in NewRelic

* v1.1
	* Update newrelic agent
	* Update apcu
	* Update xdebug
	* Update composer to v2
	* Remove prestissimo composer plugin with Composer 2

* v1.0
	* Add php-soap extension
