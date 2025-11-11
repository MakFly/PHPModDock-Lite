ARG POSTGRES_VERSION=16-alpine
FROM postgres:${POSTGRES_VERSION}

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Install additional tools
RUN apk --update add --no-cache bash

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

EXPOSE 5432
