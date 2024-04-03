FROM php:8.2-apache

ARG app_port


RUN sed -si 's/Listen 80/Listen '$app_port'/' /etc/apache2/ports.conf
RUN sed -si 's/VirtualHost .:80/VirtualHost *:'$app_port'/' /etc/apache2/sites-enabled/000-default.conf


RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    libzip-dev \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libicu-dev \
    libxml2-dev \
    libpq-dev

# Install LDAP library and dependencies
RUN apt-get update && \
    apt-get install -y libldap2-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install zip && docker-php-ext-enable zip
RUN docker-php-ext-install gd && docker-php-ext-enable gd
RUN docker-php-ext-configure intl && docker-php-ext-install intl && docker-php-ext-enable intl
RUN docker-php-ext-install soap && docker-php-ext-enable soap
RUN docker-php-ext-install pgsql pdo_pgsql && docker-php-ext-enable pgsql pdo_pgsql
RUN docker-php-ext-install exif && docker-php-ext-enable exif
RUN docker-php-ext-install opcache

# Enable the LDAP PHP extension
RUN docker-php-ext-enable ldap

COPY ./php_conf/* /usr/local/etc/php/conf.d/

RUN cd /var/www
#RUN chmod -R 0777 /var/www/wp-content

WORKDIR /var/www/html
EXPOSE $app_port
# RUN php admin/cli/install.php

