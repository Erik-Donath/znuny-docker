# Basis-Image: Aktuelles Debian Slim
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# System-Updates und alle benötigten Pakete installieren
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

# Locale auf UTF-8 setzen (wichtig für Perl)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /opt

# Znuny herunterladen und entpacken
RUN wget https://download.znuny.org/releases/znuny-latest-7.1.tar.gz && \
    tar xfz znuny-latest-7.1.tar.gz && \
    export ZNUNY_DIR=$(tar tzf znuny-latest-7.1.tar.gz | head -1 | cut -f1 -d"/") && \
    ln -s "/opt/$ZNUNY_DIR" /opt/znuny && \
    cp "/opt/$ZNUNY_DIR/Kernel/Config.pm.dist" "/opt/$ZNUNY_DIR/Kernel/Config.pm"

# Znuny-Benutzer anlegen (Debian/Ubuntu-Variante)
RUN useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash -M -N znuny

# Rechte und Besitz für Znuny setzen
RUN /opt/znuny/bin/znuny.SetPermissions.pl --znuny-user=znuny --web-group=www-data

# Cronjobs initialisieren (Kopieren der .dist-Dateien)
RUN cd /opt/znuny/var/cron && for foo in *.dist; do cp "$foo" "${foo%.dist}"; done

# Apache-Konfiguration für Znuny einbinden
RUN ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf

# Benötigte Apache-Module aktivieren
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork headers filter perl cgi && \
    a2enconf znuny

# ServerName setzen, um Apache-Warnung zu vermeiden
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

EXPOSE 80

# Cronjob für Znuny alle 5 Minuten einrichten
RUN echo "*/5 * * * * znuny /opt/znuny/bin/Cron.sh start > /dev/null 2>&1" > /etc/cron.d/znuny && \
    chmod 0644 /etc/cron.d/znuny && \
    crontab -u znuny /etc/cron.d/znuny

# entrypoint.sh in den Container kopieren und ausführbar machen
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Standard-Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
