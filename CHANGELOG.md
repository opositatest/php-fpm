Changelog php-fpm version 7.x

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