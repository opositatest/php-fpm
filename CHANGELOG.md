
Changelog php-fpm version 7.x

* v2.6
	* Update php xdeug, apcu and newrelic agent

* v2.5
	* Update settings to xdebug3

* v2.4
	* Update newrelic agent

* v2.3
	* Update dependencies

* v2.2
	* Added a handler to run all scripts in init.d folder before running the php-fpm service
	* Migrated Xdebug setting from v2 to v3

* v2.1
	* Disable distributed tracing in New Relic

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