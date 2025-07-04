#!/bin/bash
set -e

# Start the Cron daemon in the background
service cron start

# Start the Znuny Daemon as the Znuny user (important for background jobs)
su -s /bin/bash znuny -c "/opt/znuny/bin/znuny.Daemon.pl start"

# Start Apache in the foreground
exec apache2ctl -D FOREGROUND
