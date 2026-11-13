# XHTTP Server Setup and Backups

This repository contains scripts for preparing an Nginx host and backing up the
local x-ui database. The installation script does **not** install the Xray core
or configure an XHTTP inbound; those steps must be completed separately.

[initial-install.sh](./initial-install.sh) installs Nginx, Certbot, and its Nginx plugin. It copies your local
`index.html` to `/var/www/html/index.html`, replacing Nginx's default index
page, and copies your local `https_xhttp` and `https_site_only` files into
`/etc/nginx/sites-available` with the same names. It stops before installing
packages if any of the three local files is missing. Neither config is enabled
automatically.

## Local database backup

[backup.sh](./backup.sh) copies `/etc/x-ui/x-ui.db` into a dated folder under
`/root/backups/`, named `xray-backup-YYYY-MM-DD`. It also removes old matching
backup folders using `find -mtime +1`; because `find` rounds ages in 24-hour
periods, this generally matches folders at least two days old, not exactly one
day old.

## Remote backup

[backup-rsync.sh](./backup-rsync.sh) makes the same local database backup,
waits for a short random interval, then attempts to sync it to a remote host
over SSH/rsync and remove old remote backup folders.

The backup scripts cover only `/etc/x-ui/x-ui.db`; they do not back up Nginx site files, TLS certificates, or other server data.
Maintain separate backups of anything needed for a full server restore.
