ARG ELASTICSEARCH_VERSION=8.11.0
FROM docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

LABEL maintainer="Laradock Lite <maintainer@laradock-lite.io>"

# Disable X-Pack security for development
ENV discovery.type=single-node
ENV xpack.security.enabled=false
ENV xpack.security.enrollment.enabled=false
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

EXPOSE 9200 9300
