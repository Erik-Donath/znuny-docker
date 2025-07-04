# Base image: Latest Debian Slim
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# System update and install all required packages
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
        ... \
        locales \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8 (important for Perl)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /opt

# Download and extract the latest Znuny release
RUN wget https://download.znuny.org/releases/znuny-latest-7.1.tar.gz && \
    tar xfz znuny-latest-7.1.tar.gz && \
    export ZNUNY_DIR=$(tar tzf znuny-latest-7.1.tar.gz | head -1 | cut -f1 -d"/") && \
    ln -s "/opt/$ZNUNY_DIR" /opt/znuny && \
    cp "/opt/$ZNUNY_DIR/Kernel/Config.pm.dist" "/opt/$ZNUNY_DIR/Kernel/Config.pm"

# Create Znuny user (Debian/Ubuntu variant)
RUN useradd -d /opt/znuny -c 'Znuny user' -g www-data -s /bin/bash -M -N znuny

# Set permissions for Znuny
RUN /opt/znuny/bin/znuny.SetPermissions.pl --znuny-user=znuny --web-group=www-data

# Initialize cronjobs (copy .dist files)
RUN cd /opt/znuny/var/cron && for foo in *.dist; do cp "$foo" "${foo%.dist}"; done

# Link Apache configuration for Znuny
RUN ln -s /opt/znuny/scripts/apache2-httpd.include.conf /etc/apache2/conf-available/znuny.conf

# Enable required Apache modules
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork headers filter perl cgi && \
    a2enconf znuny

# Set ServerName to avoid Apache warning
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
    a2enconf servername

EXPOSE 80

# Schedule Znuny cronjob every 5 minutes
RUN echo "*/5 * * * * znuny /opt/znuny/bin/Cron.sh start > /dev/null 2>&1" > /etc/cron.d/znuny && \
    chmod 0644 /etc/cron.d/znuny && \
    crontab -u znuny /etc/cron.d/znuny

# Copy entrypoint script into container and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
