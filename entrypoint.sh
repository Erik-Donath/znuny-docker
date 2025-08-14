#!/bin/bash
set -e

trap 'service cron stop; su -s /bin/bash znuny -c "/opt/znuny/bin/znuny.Daemon.pl stop"; exit 0' SIGTERM

service cron start
su -s /bin/bash znuny -c "/opt/znuny/bin/znuny.Daemon.pl start"
exec apache2ctl -D FOREGROUND