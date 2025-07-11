# syntax=docker/dockerfile:1

FROM debian:bookworm-slim

# ---- Metadata ----
LABEL maintainer="Erik Donath"
LABEL org.opencontainers.image.title="Znuny"
ARG ZNUNY_VERSION=7.1.7
LABEL org.opencontainers.image.version="${ZNUNY_VERSION}"
LABEL org.opencontainers.image.description="This repository provides a ready-to-use Docker setup for Znuny, including Apache2, Cron, and the Znuny Daemon. MariaDB runs as a separate service for modularity and data safety. Suitable for both testing and production environments."

ENV DEBIAN_FRONTEND=noninteractive

# ---- Install dependencies ----
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apache2 \
        libapache2-mod-perl2 \
        perl \
        wget \
        tar \
        gzip \
        bash-completion \
        cron \
        libdbd-mysql-perl \
        libtimedate-perl \
        libnet-dns-perl \
        libnet-ldap-perl \
        libio-socket-ssl-perl \
        libpdf-api2-perl \
        libsoap-lite-perl \
        libtext-csv-xs-perl \
        libjson-xs-perl \
        libapache-dbi-perl \
        libxml-libxml-perl \
        libxml-libxslt-perl \
        libyaml-perl \
        libarchive-zip-perl \
        libcrypt-eksblowfish-perl \
        libencode-hanextra-perl \
        libmail-imapclient-perl \
        libtemplate-perl \
        libdatetime-perl \
        libmoo-perl \
        libyaml-libyaml-perl \
        libjavascript-minifier-xs-perl \
        libcss-minifier-xs-perl \
        libauthen-sasl-perl \
        libauthen-ntlm-perl \
        libhash-merge-perl \
        libical-parser-perl \
        libspreadsheet-xlsx-perl \
        libdata-uuid-perl \
        mariadb-client \
        sudo \
        locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Set locale to UTF-8 ----
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /opt

# ---- Download and extract Znuny (robust version handling) ----
ENV ZNUNY_VERSION=${ZNUNY_VERSION}

RUN wget https://download.znuny.org/releases/znuny-${ZNUNY_VERSION}.tar.gz && \
    tar xfz znuny-${ZNUNY_VERSION}.tar.gz && \
    export ZNUNY_DIR=$(tar tzf znuny-${ZNUNY_VERSION}.tar.gz | head -1 | cut -f1 -d"/") && \
    if [ "$ZNUNY_DIR" != "znuny-${ZNUNY_VERSION}" ]; then \
        mv "$ZNUNY_DIR" "znuny-${ZNUNY_VERSION}"; \
    fi && \
    ln -s "/opt/znuny-${ZNUNY_VERSION}" /opt/znuny && \
    cp "/opt/znuny-${ZNUNY_VERSION}/Kernel/Config.pm.dist" "/opt/znuny-${ZNUNY_VERSION}/Kernel/Config.pm"

# ---- Create Znuny user ----
RUN useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash -M -N znuny

# ---- Set permissions and ownership for Znuny ----
RUN /opt/znuny/bin/znuny.SetPermissions.pl --znuny-user=znuny --web-group=www-data

# ---- Initialize cronjobs ----
RUN cd /opt/znuny/var/cron && for foo in *.dist; do cp "$foo" "${foo%.dist}"; done

# ---- Include Apache configuration for Znuny ----
RUN ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf

# ---- Enable required Apache modules ----
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork headers filter perl cgi && \
    a2enconf znuny

# ---- Set ServerName to avoid Apache warning ----
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

EXPOSE 80

# ---- Set up Znuny cronjob to run every 5 minutes ----
RUN echo "*/5 * * * * znuny /opt/znuny/bin/Cron.sh start > /dev/null 2>&1" > /etc/cron.d/znuny && \
    chmod 0644 /etc/cron.d/znuny && \
    crontab -u znuny /etc/cron.d/znuny

# ---- Copy entrypoint.sh into the container and make it executable ----
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ---- Default entrypoint ----
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
