FROM quay.io/tayloredtechnology/basal:base

MAINTAINER Keidrych Anton-Oates <keidrych@tayloredtechnology.net>

# 0@Cache -- Perma-Cached
# TODO ensure that node script cleans up after itself (APT cache clear)
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN install_packages nodejs
