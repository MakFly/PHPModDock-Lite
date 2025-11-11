ARG MYSQL_VERSION=8.0
FROM mysql:${MYSQL_VERSION}

LABEL maintainer="PHPModDock-Lite <maintainer@phpmoddock-lite.io>"

# Copy custom MySQL configuration
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Set timezone
ARG TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

CMD ["mysqld"]

EXPOSE 3306
