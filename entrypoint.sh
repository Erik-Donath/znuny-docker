#!/bin/bash
set -e

# Starte Cron im Hintergrund
service cron start

# Starte den Znuny Daemon als Znuny-User (wichtig für Hintergrundjobs)
su -s /bin/bash znuny -c "/opt/znuny/bin/znuny.Daemon.pl start"

# Starte Apache im Vordergrund
exec apachectl -D FOREGROUND
