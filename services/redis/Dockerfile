FROM redis:7-alpine

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Copy custom Redis configuration
COPY redis.conf /usr/local/etc/redis/redis.conf

# Install bash for easier debugging
RUN apk --update add --no-cache bash

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Clean up
RUN rm -rf /var/cache/apk/*

EXPOSE 6379

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
