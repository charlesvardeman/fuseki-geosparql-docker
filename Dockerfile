FROM java:8-jre-alpine

MAINTAINER Charles F Vardeman II <cvardema@nd.edu>

RUN apk add --update \
    && apk add --no-cache pwgen linux-headers bash ca-certificates wget unzip\
    && rm -rf /var/cache/apk/*

# Update below according to https://jena.apache.org/download/
ENV GEO_FUSEKI_SHA512 562daa37e4f28579a3dca2d5b0ddcfd55400e06aa17b805a32d12b5ceda1efe9f7de513d8eb0854e06cc0fe7dfa6b5b7e5b3bb07a9da931a06bf7dd2d70573d3
ENV GEO_FUSEKI_VERSION 1.1.2
ENV GEO_FUSEKI_DOWNLOAD https://github.com/galbiston/geosparql-fuseki/releases/download

# Installation folder
RUN mkdir /jena-fuseki
ENV FUSEKI_HOME /jena-fuseki

WORKDIR /tmp

#https://github.com/galbiston/geosparql-fuseki/releases/download/v1.1.0/geosparql-fuseki-1.1.0.zip
#https://github.com/galbiston/geosparql-fuseki/releases/download/v1.1.2/geosparql-fuseki-1.1.2.zip
# md5 checksum
RUN echo "$GEO_FUSEKI_SHA512  geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip" > geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip.sha512
# Download/check/unpack/move in one go (to reduce image size)
# && sha512sum -c geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip.sha512 \
RUN wget ${GEO_FUSEKI_DOWNLOAD}/v${GEO_FUSEKI_VERSION}/geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip \
    && sha512sum -c geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip.sha512 \
    && unzip geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip \
    && mv geosparql-fuseki-${GEO_FUSEKI_VERSION}/* $FUSEKI_HOME \
    && rm geosparql-fuseki-${GEO_FUSEKI_VERSION}.zip 

ENV GOSU_VERSION 1.10
RUN set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
        curl \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && pkill -9 gpg-agent \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

# Adding user without root privileges alongside a user group
RUN addgroup -S nonroot \
    && adduser -S -g nonroot nonroot

# As "localhost" is often inaccessible within Docker container,
# we'll enable basic-auth with a preset admin password
# (which we'll generate on start-up)
#COPY shiro.ini /jena-fuseki/shiro.ini
#
#COPY docker-entrypoint.sh /

# Adding configuration to the Graph Store and associated data
# at the same time modifing start script
#ADD data /data/fuseki/config/data/
#COPY config.ttl /data/fuseki/config/config.ttl
#COPY start-fuseki.sh /jena-fuseki/start-fuseki.sh
# Create volume for data store

#COPY load.sh /jena-fuseki/
#COPY tdbloader /jena-fuseki/
#RUN chmod 755 /jena-fuseki/load.sh /jena-fuseki/tdbloader /jena-fuseki/start-fuseki.sh /docker-entrypoint.sh

# Config and data volume
# The volume needs to be set after the directory has been created to avoid
# permissions issues
VOLUME /data/fuseki/fuseki_DB
ENV FUSEKI_BASE /data/fuseki
COPY ./data/geosparql_test.rdf /jena-fuseki
COPY ./docker-entrypoint.sh /jena-fuseki

# setting environment variables for entrypoint script
# setting also directories to be owned by the nonroot user
ENV GOSU_USER nonroot:nonroot
ENV GOSU_CHOWN /jena-fuseki /data

# Where we start our server from
WORKDIR /jena-fuseki

EXPOSE 3030

ENTRYPOINT ["/jena-fuseki/docker-entrypoint.sh"]
#CMD ["/jena-fuseki/bin/start-fuseki.sh"]
# ENTRYPOINT [ "/bin/sh" ]