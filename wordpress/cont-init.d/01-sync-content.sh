#!/usr/bin/with-contenv bash

# Sync latest version of server control & keys repos

# Retrieve any environmental variables direct from the container as this script must be able to
# be run outside of the normal s6 loading system
# WEBSITEBRANCH=$(cat /var/run/s6/container_environment/WEBSITEBRANCH)
# Generic assumption that if WEBSITEBRANCH=null the core docker template image is being compiled as this file
# is being run solo and not part of the s6 container load chain
# if [ -z $WEBSITEBRANCH ]; then
# 	WEBSITEBRANCH=master
# else

	# Create symbolic links to the relevant directories
	# cd /app
	# rm -rf core-domain-salts mysql-connection
	# ln -s /app/server-scripts/core-domain-salts core-domain-salts
	# ls -s /app/server-scripts/mysql-connection mysql-connection
	# cd /etc/nginx
	# rm -rf hosted-sites certificates
	# ln -s /app/server-scripts/hostnames hosted-sites

# s6-envuidgid www-data

# Create public directory from mounted directories for serving with NGINX
[ ! -d /public ] && mkdir /public
cd /public/
# wp-config.php hard mounted @ / via DockerFile

# Update website to latest version
if [ ! -z $INSTALL_VERSION ]; then
	# # Download & Install the tagged version of WordPress
	# [ ! -d /wordpress ] && mkdir /wordpress
	# cd /wordpress
	# wget --no-check-certificate https://github.com/WordPress/WordPress/archive/$INSTALL_VERSION.zip -O /tmp/$INSTALL_VERSION.zip
	# unzip -o -q /tmp/$INSTALL_VERSION.zip -d /tmp/
	# rm -rf /tmp/WordPress-$INSTALL_VERSION/wp-content/*
	# rm -rf /tmp/WordPress-$INSTALL_VERSION/wp-config.php
	# mv /tmp/WordPress-$INSTALL_VERSION/* /public
	# # cleanup
	# rm /tmp/$INSTALL_VERSION.zip
	# rm -rf /tmp/WordPress-$INSTALL_VERSION
# else
	echo "INSTALL_VERSION not specified..."
	echo "Running WordPress Version:" $(grep wp_version /wordpress/wp-includes/version.php | tail -1 | cut -d"'" -f2)
fi

# Link the custom content folders (overrinding the template)
# Custom Uploads
if [ -z $INSTALL_VERSION ]; then
	rm -rf /public/wp-content/uploads
	ln -s /app/uploads /public/wp-content/uploads
	# Custom Themes
	while IFS= read -r -d $'\0' f; do
	  dirname=$(basename $f | tr -d ' ')
	  [ "$dirname" == "themes" ] && continue
	  rm -rf /public/wp-content/themes/$dirname
		ln -s /app/themes/$dirname /public/wp-content/themes/$dirname
	done < <(find wp-content/themes -maxdepth 1 -type d -print0)
	# Custom Plugins
	while IFS= read -r -d $'\0' f; do
	  dirname=$(basename $f | tr -d ' ')
	  [ "$dirname" == "plugins" ] && continue
	  rm -rf /public/wp-content/plugins/$dirname
		ln -s /app/plugins/$dirname /public/wp-content/plugins/$dirname
	done < <(find wp-content/plugins -maxdepth 1 -type d -print0)
	# EWWW Mappings
	[ ! -d /app/ewww ] && mkdir -p /app/ewww
	rm -rf /public/wp-content/ewww
	ln -s /app/ewww /public/wp-content/ewww
	# Required Logging
	[ ! -d /app/logs ] && mkdir -p /app/logs
	rm -rf /public/wp-content/logs
	ln -s /app/logs /public/wp-content/logs
	# Database Mappings is not necessary as write directly to the mount volume
else
	cp -R /app/* /public/wp-content
	wget -N --no-verbose --quiet $(curl -s https://wordpress.org/plugins/sqlite-integration/ | egrep -o "https:\/\/downloads.wordpress.org\/plugin\/[^\"]+") -O /tmp/sqlite.zip
	unzip /tmp/sqlite.zip -d /public/wp-content/plugins/
	rm /tmp/sqlite.zip
	cp /public/wp-content/plugins/sqlite-integration/db.php /public/wp-content
fi
