FROM rabbitmq:3-management-alpine

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Install bash for easier debugging
RUN apk --update add --no-cache bash

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Enable plugins
RUN rabbitmq-plugins enable --offline rabbitmq_management rabbitmq_prometheus

# Clean up
RUN rm -rf /var/cache/apk/*

EXPOSE 5672 15672
