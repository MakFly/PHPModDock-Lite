ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Set working directory
WORKDIR /var/www

# Install system dependencies and PHP extensions in optimized layers
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Version control
    git \
    # Networking
    curl \
    wget \
    # Image processing libs
    libpng-dev \
    # Text processing
    libonig-dev \
    libxml2-dev \
    # Compression
    libzip-dev \
    zip \
    unzip \
    # Database libs
    libpq-dev \
    # Internationalization
    libicu-dev \
    # Editor
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

###########################################################################
# PHP Extensions
###########################################################################

# Install all PHP extensions in a single layer for better caching
RUN install-php-extensions \
    # Database
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    # Image processing
    gd \
    # Text & Localization
    intl \
    # File handling
    zip \
    exif \
    # Math & Processing
    bcmath \
    opcache \
    pcntl \
    sockets

###########################################################################
# Redis Extension
###########################################################################

ARG INSTALL_REDIS=true
RUN if [ ${INSTALL_REDIS} = true ]; then \
    install-php-extensions redis \
;fi

###########################################################################
# XDebug Extension
###########################################################################

ARG INSTALL_XDEBUG=false
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    install-php-extensions xdebug \
;fi

###########################################################################
# Composer
###########################################################################

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

###########################################################################
# Node.js & NPM (optional)
###########################################################################

ARG INSTALL_NODE=false
ARG NODE_VERSION=20

RUN if [ ${INSTALL_NODE} = true ]; then \
    curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
;fi

###########################################################################
# Symfony CLI (optional)
###########################################################################

ARG INSTALL_SYMFONY_CLI=false

RUN if [ ${INSTALL_SYMFONY_CLI} = true ]; then \
    wget https://get.symfony.com/cli/installer -O symfony-installer \
    && wget https://get.symfony.com/cli/installer.sha256 -O symfony-installer.sha256 \
    && echo "$(cat symfony-installer.sha256)  symfony-installer" | sha256sum -c - \
    && bash symfony-installer \
    && rm symfony-installer symfony-installer.sha256 \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony \
;fi

###########################################################################
# PHP Configuration
###########################################################################

# Copy custom php.ini
COPY config/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Copy XDebug configuration
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    echo '[xdebug]' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'zend_extension=xdebug.so' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.mode=debug,coverage,develop' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_host=host.docker.internal' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.client_port=9003' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.start_with_request=yes' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo 'xdebug.idekey=VSCODE' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
;fi

###########################################################################
# System Configuration (Timezone, User, Permissions)
###########################################################################

ARG TZ=UTC
ARG PUID=1000
ARG PGID=1000

# Configure system settings in a single layer
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    printf '[PHP]\ndate.timezone = "%s"\n' $TZ > /usr/local/etc/php/conf.d/tzone.ini && \
    groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data && \
    chown -R www-data:www-data /var/www

###########################################################################
# Caddyfile Configuration
###########################################################################

# Copy simplified Caddyfile (configured via environment variables)
COPY config/Caddyfile /etc/frankenphp/Caddyfile

# Copy default HTML files for localhost
COPY html /usr/share/frankenphp/html

# Expose ports
EXPOSE 80 443 443/udp

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Run FrankenPHP
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile"]
