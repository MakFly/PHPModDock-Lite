FROM php:8.3-cli-alpine

LABEL maintainer="Laradock Lite <maintainer@laradock-lite.io>"

# Set working directory
WORKDIR /var/www

###########################################################################
# System Dependencies
###########################################################################

# Install system packages in a single layer for better caching
RUN apk --update add --no-cache \
    # CLI tools
    bash \
    curl \
    git \
    openssh-client \
    make \
    vim \
    nano \
    wget \
    zip \
    unzip \
    # Build tools
    g++ \
    gcc \
    libc-dev \
    autoconf \
    linux-headers \
    # Image processing
    imagemagick-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    # PHP extensions deps
    libzip-dev \
    libxml2-dev \
    oniguruma-dev \
    icu-dev \
    # Database clients
    mysql-client \
    postgresql-dev \
    postgresql-client \
    # System utilities
    tzdata \
    shadow \
    procps

###########################################################################
# PHP Extensions
###########################################################################

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
# XDebug Extension
###########################################################################

ARG INSTALL_XDEBUG=false

RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    apk add --no-cache --virtual .xdebug-deps $PHPIZE_DEPS \
    && pecl install xdebug-3.3.0 \
    && docker-php-ext-enable xdebug \
    && apk del .xdebug-deps \
;fi

###########################################################################
# Composer
###########################################################################

ARG COMPOSER_VERSION=2

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --${COMPOSER_VERSION}

# Install global Composer packages
ARG INSTALL_LARAVEL_INSTALLER=false
ARG INSTALL_SYMFONY_CLI=false

RUN if [ ${INSTALL_LARAVEL_INSTALLER} = true ]; then \
    composer global require laravel/installer \
;fi

###########################################################################
# Symfony CLI
###########################################################################

RUN if [ ${INSTALL_SYMFONY_CLI} = true ]; then \
    wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony \
;fi

###########################################################################
# Node.js & Package Managers
###########################################################################

ARG INSTALL_NODE=true
ARG NODE_VERSION=20
ARG INSTALL_YARN=false
ARG INSTALL_PNPM=false

# Install Node.js and package managers in a single layer
RUN if [ ${INSTALL_NODE} = true ]; then \
    apk add --no-cache nodejs npm && \
    if [ ${INSTALL_YARN} = true ]; then npm install -g yarn; fi && \
    if [ ${INSTALL_PNPM} = true ]; then npm install -g pnpm; fi \
;fi

###########################################################################
# System Configuration (Git, SSH, Timezone, User)
###########################################################################

ARG TZ=UTC
ARG PUID=1000
ARG PGID=1000

# Configure system settings in a single layer
RUN git config --global --add safe.directory '*' && \
    mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data && \
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> /home/www-data/.bashrc && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Copy workspace scripts
COPY aliases.sh /home/www-data/aliases.sh
COPY workspace-menu.sh /home/www-data/workspace-menu.sh
COPY workspace-helpers.sh /home/www-data/workspace-helpers.sh

# Make scripts executable
RUN chmod +x /home/www-data/workspace-menu.sh && \
    chmod +x /home/www-data/workspace-helpers.sh && \
    chown www-data:www-data /home/www-data/aliases.sh && \
    chown www-data:www-data /home/www-data/workspace-menu.sh && \
    chown www-data:www-data /home/www-data/workspace-helpers.sh

# Configure bash to load scripts
RUN echo "" >> /home/www-data/.bashrc && \
    echo "# Laradock Lite Workspace Configuration" >> /home/www-data/.bashrc && \
    echo "source ~/aliases.sh" >> /home/www-data/.bashrc && \
    echo "source ~/workspace-helpers.sh" >> /home/www-data/.bashrc && \
    echo "" >> /home/www-data/.bashrc && \
    echo "# Show interactive menu on first login" >> /home/www-data/.bashrc && \
    echo "source ~/workspace-menu.sh" >> /home/www-data/.bashrc

# Set default user
USER www-data

# Keep container running
CMD ["tail", "-f", "/dev/null"]

EXPOSE 22
