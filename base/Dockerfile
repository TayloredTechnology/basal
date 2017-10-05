FROM bitnami/minideb:stretch

MAINTAINER Keidrych Anton-Oates <keidrych@tayloredtechnology.net>

# 0@Cache -- Perma-Cached
# Base Only Packages
ENV DEBIAN_FRONTEND=noninteractive
# RUN install_packages netselect-apt curl && \
#		netselect-apt -n stretch

RUN install_packages sqlite3 curl httpie procps htop ssmtp vim locales apt-transport-https lsb-release ca-certificates entr gnupg
RUN update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
		locale-gen en_US.UTF-8 && \
		dpkg-reconfigure locales && \
		mkdir -p /ssmtp && mkdir -p /app
#	wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
#	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

ARG VFETCH=v0.1.1
RUN	curl --location -o /bin/fetch https://github.com/gruntwork-io/fetch/releases/download/$VFETCH/fetch_linux_amd64 && \
		chmod a+x /bin/fetch
#	fetch --repo="https://github.com/gruntwork-io/fetch" --tag=">=0.1.1" --release-asset="fetch_linux_amd64" /bin/ && \
#	mv /bin/fetch_linux_amd64 /bin/fetch && \
#	chmod a+x /bin/fetch

ARG VS6=v1.19.1.1
RUN fetch --repo="https://github.com/just-containers/s6-overlay" --tag="$VS6" --release-asset="s6-overlay-amd64.tar.gz" /tmp/ && \
		tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

ARG VCONFD=0.12.1
RUN fetch --repo="https://github.com/bacongobbler/confd" --tag="=v$VCONFD" --release-asset="confd-$VCONFD-linux-amd64" /usr/bin/ && \
		mv /usr/bin/confd-$VCONFD-linux-amd64 /usr/bin/confd && \
		chmod +x /usr/bin/confd

ARG VWEBHOOK=2.6.4
RUN fetch --repo="https://github.com/adnanh/webhook" --tag=">=$VWEBHOOK" --release-asset="webhook-linux-amd64.tar.gz" /tmp/ && \
		tar xvf /tmp/webhook-linux-amd64.tar.gz && mv webhook-linux-amd64/webhook /usr/bin/webhook && rm -rf webhook-linux-amd64

# S6 always uses /init to run
ENTRYPOINT ["/init"]

# Directory Structure
# Not mounted as a volume to prevent downstream services from breaking when volume unmounts in layers i.e. npm install
# /app for the application (irrespective of language)
# VOLUME ["/app"]

WORKDIR /app

# Confd Configuration files
COPY confd/ /etc/confd/
