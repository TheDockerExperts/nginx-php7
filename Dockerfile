FROM ubuntu:16.04
MAINTAINER Alex Kondratiev <alex@itsyndicate.org>

ENV NGINX_VERSION 1.11.10-1~xenial

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-get update && \
    apt-get install -y \
            language-pack-en-base \
            software-properties-common && \
    add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
            ca-certificates \
            php7.1 \
            php7.1-mbstring \
            php7.1-mcrypt \
            php7.1-xml \
            php7.1-fpm \
            php7.1-gd \
            php7.1-curl \
            php7.1-imagick \
            php7.1-pgsql \
            php7.1-mysql \
            php7.1-opcache \
            php7.1-zip \
            php7.1-soap \
            php7.1-xsl \
            php7.1-intl \
            php-memcached \
            php-memcache \
            curl \
            openssl \
            ca-certificates \
            wget \
            libwww-perl \
            libcrypt-ssleay-perl \
            rsyslog \
            run-one \
            sudo \
            ssmtp \
            python-pip \
            python-setuptools \
            supervisor && \
    echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" > /etc/apt/sources.list.d/nginx.list && \
    wget -O /tmp/nginx_signing.key http://nginx.org/keys/nginx_signing.key && \
    apt-key add /tmp/nginx_signing.key && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
            nginx=$NGINX_VERSION && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install supervisor-stdout

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# NginX
COPY conf/nginx /etc/nginx

# PHP
COPY conf/php/7.1 /etc/php/7.1/
RUN sed -i -e "s/;\?daemonize\s*=\s*yes/daemonize = no/" /etc/php/7.1/fpm/php-fpm.conf
RUN mkdir -p /run/php /var/log/app_engine && chown www-data.www-data /run/php

# SUPERVISOR
COPY conf/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

CMD /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
