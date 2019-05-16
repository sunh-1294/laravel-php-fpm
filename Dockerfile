FROM php:7.2-fpm

MAINTAINER Nguyen Huu Su <huusu1996@gmail.com>

ENV TERM xterm

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmcrypt-dev \
    vim \
    zlib1g-dev libicu-dev g++ \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*
# configure mcrypt
RUN apt-get update \
	&& apt-get install -y libmcrypt-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& pecl install mcrypt-1.0.1 \
	&& docker-php-ext-enable mcrypt
# gmp
RUN apt-get update \
	&& apt-get install -y libgmp-dev re2c libmhash-dev libmcrypt-dev file \
	&& ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
	&& docker-php-ext-configure gmp \
    && docker-php-ext-install gmp

# configure gd library
RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-jpeg-dir=/usr/lib \
    --with-freetype-dir=/usr/include/freetype2

# configure intl
RUN docker-php-ext-configure intl

# Install mongodb, xdebug
RUN pecl install mongodb \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install extensions using the helper script provided by the base image
RUN docker-php-ext-install \
    bcmath \
    pdo_mysql \
    pdo_pgsql \
    gd \
    intl \
    zip

RUN usermod -u 1000 www-data

WORKDIR /var/www/laravel

ADD ./laravel.ini /usr/local/etc/php/conf.d
ADD ./laravel.pool.conf /usr/local/etc/php-fpm.d/

CMD ["php-fpm"]

EXPOSE 9000
