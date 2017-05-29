#!/usr/bin/execlineb -P

with-contenv
s6-envuidgid www-data

define nginxd /etc/nginx

foreground {
	if -n { s6-test -d ${nginxd}/sites-enabled }
	{ mkdir -p /etc/nginx/sites-enabled }
}

foreground {
	if -n { s6-test -d ${nginxd}/sites-available }
	{ mkdir -p /etc/nginx/sites-available }
}

foreground {
	if { s6-test -z $ROOT_DOMAIN }
	define ROOT_DOMAIN localhost
}

confd -backend env --onetime
