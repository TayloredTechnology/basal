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
cd /app/
# wp-config.php hard mounted @ / via DockerFile

echo "Running WordPress Version:" $(grep wp_version /wordpress/wp-includes/version.php | tail -1 | cut -d"'" -f2)

# Link the custom content folders (overrinding the template)
# Custom Uploads
if [ ! -e /app/wp_installed ]; then
	touch /app/wp_installed
	[ ! -d /app/plugins ] && mkdir -p /app/plugins
	# cp -R /app/* /public/wp-content
	wget -N --no-verbose --quiet $(curl -s https://wordpress.org/plugins/sqlite-integration/ | egrep -o "https:\/\/downloads.wordpress.org\/plugin\/[^\"]+") -O /tmp/sqlite.zip
	unzip /tmp/sqlite.zip -d /app/plugins/
	rm /tmp/sqlite.zip
fi

# Drop-ins
cp /app/plugins/sqlite-integration/db.php /public/wp-content

# Uploads
rm -rf /public/wp-content/uploads
ln -s /app/uploads /public/wp-content/uploads
# Custom Themes
while IFS= read -r -d $'\0' f; do
	dirname=$(basename $f | tr -d ' ')
	[ "$dirname" == "themes" ] && continue
	rm -rf /public/wp-content/themes/$dirname
	ln -s /app/themes/$dirname /public/wp-content/themes/$dirname
done < <(find themes -maxdepth 1 -type d -print0)
# Custom Plugins
while IFS= read -r -d $'\0' f; do
	dirname=$(basename $f | tr -d ' ')
	[ "$dirname" == "plugins" ] && continue
	rm -rf /public/wp-content/plugins/$dirname
	ln -s /app/plugins/$dirname /public/wp-content/plugins/$dirname
done < <(find plugins -maxdepth 1 -type d -print0)
# EWWW Mappings
[ ! -d /app/ewww ] && mkdir -p /app/ewww
rm -rf /public/wp-content/ewww
ln -s /app/ewww /public/wp-content/ewww
# Required Logging
[ ! -d /app/logs ] && mkdir -p /app/logs
rm -rf /public/wp-content/logs
ln -s /app/logs /public/wp-content/logs
# Database Mappings is not necessary as write directly to the mount volume

chown -R www-data:www-data /app
chown -R www-data:www-data /public
