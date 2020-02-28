#!/bin/bash
set -e

apt update && apt install -y curl --no-install-recommends

/etc/init.d/nginx start

if [[ $(curl -s 'http://localhost/') != 'Ok' ]];then
	exit 1
fi
