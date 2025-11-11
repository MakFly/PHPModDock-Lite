FROM nginx:alpine

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Install dependencies
RUN apk update \
    && apk upgrade \
    && apk --update add logrotate \
    && apk add --no-cache openssl bash \
    && apk add --no-cache curl

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf

# Copy default HTML files
COPY html /usr/share/nginx/html

# Create log directory
RUN mkdir -p /var/log/nginx && \
    touch /var/log/nginx/access.log && \
    touch /var/log/nginx/error.log

# Add user
ARG PUID=1000
ARG PGID=1000

RUN addgroup -g ${PGID} phpmoddock && \
    adduser -D -u ${PUID} -G phpmoddock phpmoddock

# Clean up
RUN rm -rf /var/cache/apk/*

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

EXPOSE 80 443
