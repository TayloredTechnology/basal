#!/usr/bin/with-contenv sh

# Reset the database back to normal
cd /app/uploads-db
unzip -q cyberspacedtesting.resetter.zip
mv app/uploads-db/default_wordpress.sqlite.backup default_wordpress.sqlite
rm -rf app

# Reset NGINX cache
rm -rf /var/lib/nginx/tmp/fastcgi/*

# Reset Redis Cache
redis-cli FLUSHALL

# Reset permissions
chown -R nginx:root /app/uploads-db

# Clear caches
# restart php & nginx
kill $(ps | grep master | head -n -1 | sed 's/^ *//' | cut -d' ' -f 1)
# restart redis
kill $(ps | grep redis-server | head -n -1 | sed 's/^ *//' | cut -d' ' -f 1)

echo "All is Reset"

