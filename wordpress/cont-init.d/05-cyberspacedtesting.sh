#!/usr/bin/execlineb -P

with-contenv
s6-envuidgid www-data

foreground {
	if { s6-test -n $WP_RESET }
		foreground { ln -s /resetter /public/resetter }
		foreground { chmod +x /public/resetter/*.sh }
}

# if [[ $(echo $ROOT_DOMAIN | grep "cyberspaced" | wc -c) > 0 ]]; then
# 	cd /app/website/scripts/
# 	chmod +x *.sh
# fi
