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

echo "Running WordPress Version:" $(grep wp_version /public/wp-includes/version.php | tail -1 | cut -d"'" -f2)

# check for critical directories, create if necessary
[ ! -d /app/plugins ] && mkdir -p /app/plugins
[ ! -d /app/themes ] && mkdir -p /app/themes
[ ! -d /app/ewww ] && mkdir -p /app/ewww
[ ! -d /app/logs ] && mkdir -p /app/logs

# check if running from upstream template
if [ -e /public/wp-content ]; then
	# WordPress will be unable to install plugins as not directly operating on a template
	# Merge custom plugins into the template & serve
	# Custom Themes
	while IFS= read -r -d $'\0' f; do
		dirname=$(basename $f | tr -d ' ')
		[ "$dirname" == "themes" ] && continue
		rm -rf /public/wp-content/themes/$dirname
		ln -s /app/themes/$dirname /public/wp-content/themes/$dirname
	done < <(find /app/themes -maxdepth 1 -type d -print0)
	# Custom Plugins
	while IFS= read -r -d $'\0' f; do
		dirname=$(basename $f | tr -d ' ')
		[ "$dirname" == "plugins" ] && continue
		rm -rf /public/wp-content/plugins/$dirname
		ln -s /app/plugins/$dirname /public/wp-content/plugins/$dirname
	done < <(find /app/plugins -maxdepth 1 -type d -print0)

	# TODO safely merge in the additional optimised tracking @ ewww
	rm -rf /public/wp-content/ewww
	rm -rf /public/wp-content/logs
else
	# Creating a template, create the initial mapping (persisted to volume)
	# Able to be persisted to Docker Image through script execution
	# TODO persistance script
	mkdir -p /public/wp-content
	ln -s /app/plugins /public/wp-content/plugins
	ln -s /app/themes /public/wp-content/themes

fi

ln -s /app/ewww /public/wp-content/ewww
ln -s /app/logs /public/wp-content/logs
# Database Mappings is not necessary as write directly to the mount volume

# Functionality critical plugins
if [ ! -d /public/wp-content/plugins/sqlite-integration ]; then
	wget -N --no-verbose --quiet $(curl -s https://wordpress.org/plugins/sqlite-integration/ | egrep -o "https:\/\/downloads.wordpress.org\/plugin\/[^\"]+") -O /tmp/sqlite.zip
	unzip /tmp/sqlite.zip -d /public/wp-content/plugins/
	rm /tmp/sqlite.zip
fi

# Drop-ins
cp /public/wp-content/plugins/sqlite-integration/db.php /public/wp-content/db.php

# Clear uploads to only this website's instance
rm -rf /public/wp-content/uploads
ln -s /app/uploads /public/wp-content/uploads

# Fix permissions (must be fixed via a script file)
chown -R www-data:www-data /app
chown -R www-data:www-data /public
