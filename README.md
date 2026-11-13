# XHTTP Server Setup and Backups

This repository contains scripts for preparing an Nginx host and backing up the
local x-ui database. The installation script does **not** install the Xray core
or configure an XHTTP inbound; those steps must be completed separately.

The script installs Nginx, Certbot, its Nginx plugin, Git, and wget. It removes
the default Nginx index page and places the tracked files from the
[restaurant website repository](https://github.com/YaninaTrekhleb/restaurant-website)
directly in `/var/www/html` (without copying its `.git` metadata). It stops if
that directory already contains other files, so review or back them up before
running the installer.

Once DNS and the selected Nginx site are ready, request a certificate for your
own domain (replace the example domain):

```bash
sudo certbot --nginx -d example.com
```

It also downloads `default_https_site_only` and `default_https` into
`/etc/nginx/sites-available`. The script does **not** enable either site or
restart Nginx. Review both files and select only the configuration appropriate
for your server. After enabling your chosen configuration, validate and reload
Nginx:

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
