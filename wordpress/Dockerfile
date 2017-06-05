FROM tayloredtechnology.azurecr.io/basal:base

MAINTAINER Keidrych Anton-Oates <keidrych@tayloredtechnology.net>

RUN	install_packages php-fpm unzip php-curl php-zip php-xml php-phar php-intl php-dom php-xmlreader php-ctype php-mbstring php-gd php-sqlite3

#RUN fetch --repo="https://github.com/h5bp/server-configs-nginx"  --tag=">=2.0.0" /etc/nginx/ && \
#		sed -i '/user www/c\user www-data;' /etc/nginx/nginx.conf && \
#		sed -i '/\/nginx.pid/c\pid \/run\/nginx.pid;' /etc/nginx/nginx.conf && \
#		sed -i '/daemonize/c\daemonize = no' /etc/php/*/fpm/php-fpm.conf

#RUN install_packages nginx-light
#RUN mkdir -p /usr/share/nginx/logs && \
#		ln -sf /dev/stdout /usr/share/nginx/logs/access.log && \
#    ln -sf /dev/stderr /usr/share/nginx/logs/error.log

RUN curl https://getcaddy.com | bash

# Service Required Ports
EXPOSE 80

# Install WordPress Core
ARG INSTALL_VERSION=4.7.5
# Totally Remove the wp-content directory from a clean install to check if running from template or custom
RUN curl -L -o /tmp/$INSTALL_VERSION.zip https://github.com/WordPress/WordPress/archive/$INSTALL_VERSION.zip && \
	unzip -o -q /tmp/$INSTALL_VERSION.zip -d /tmp/ && \
	rm -rf /tmp/WordPress-$INSTALL_VERSION/wp-content && \
	rm -rf /tmp/WordPress-$INSTALL_VERSION/wp-config.php && \
	mkdir /public && \
	mv /tmp/WordPress-$INSTALL_VERSION/* /public && \
	rm /tmp/$INSTALL_VERSION.zip && \
	rm -rf /tmp/WordPress-$INSTALL_VERSION

# @Cache -- Bust Cache to ensure pulling latest committed version
ARG BURST_FILE_CACHE=1

ADD https://www.amdoren.com/api/timezone.php?api_key=RFhc7DAPqLDxDQespy5HPiWFvNMDQr&loc=Brisbane /tmp/bustcache
# Add ability to Reset PHP Caches
ADD resetter/ /resetter

# Start Daemons
ADD services.d/ /etc/services.d/
ADD cont-init.d/ /etc/cont-init.d/
RUN chmod +x /etc/services.d/* && chmod +x /etc/cont-init.d/*

#ADD fix-attrs.d/ /etc/fix-attrs.d/

ADD caddyserver/Caddyfile /Caddyfile
ENV CADDYPATH /app/.caddy/

# Confd Configuration files
COPY confd/ /etc/confd/

ADD php-fpm/conf.d/opcache.ini /etc/php/7.0/fpm/conf.d/10-opcache.ini

# Override NGINX Default Install
#ADD nginx-conf/ /etc/nginx/
