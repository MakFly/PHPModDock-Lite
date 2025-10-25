FROM php:8.2-fpm-alpine

LABEL maintainer="Laradock Lite <maintainer@laradock-lite.io>"

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apk --update add --no-cache \
    bash \
    curl \
    g++ \
    gcc \
    git \
    imagemagick-dev \
    libc-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    libxml2-dev \
    make \
    mysql-client \
    postgresql-dev \
    oniguruma-dev \
    openssh-client \
    icu-dev \
    autoconf \
    tzdata

###########################################################################
# PHP Extensions
###########################################################################

# Install core extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        mysqli \
        opcache \
        intl \
        zip \
        bcmath \
        exif \
        gd \
        pcntl \
        sockets

###########################################################################
# Redis Extension
###########################################################################

ARG INSTALL_PHPREDIS=true

RUN if [ ${INSTALL_PHPREDIS} = true ]; then \
    apk add --no-cache pcre-dev $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del pcre-dev $PHPIZE_DEPS \
;fi

###########################################################################
# Imagick Extension
###########################################################################

ARG INSTALL_IMAGEMAGICK=true

RUN if [ ${INSTALL_IMAGEMAGICK} = true ]; then \
    apk add --no-cache --virtual .imagick-deps imagemagick-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del .imagick-deps \
;fi

###########################################################################
# XDebug Extension
###########################################################################

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    apk add --no-cache --virtual .xdebug-deps $PHPIZE_DEPS \
    && pecl install xdebug-3.3.0 \
    && docker-php-ext-enable xdebug \
    && apk del .xdebug-deps \
;fi

# Copy xdebug configuration
COPY ./config/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

###########################################################################
# PHP Configuration
###########################################################################

# Copy custom php.ini
COPY ./config/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Configure PHP-FPM
RUN sed -i 's/pm.max_children = 5/pm.max_children = 50/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.start_servers = 2/pm.start_servers = 10/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 5/g' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 15/g' /usr/local/etc/php-fpm.d/www.conf

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Clean up
RUN rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Set user
ARG PUID=1000
ARG PGID=1000

RUN addgroup -g ${PGID} laradock && \
    adduser -D -u ${PUID} -G laradock laradock

# Switch to non-root user
USER laradock

EXPOSE 9000

CMD ["php-fpm"]
