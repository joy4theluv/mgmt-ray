# XHTTP Server Setup and Backups

This repository contains scripts for preparing an Nginx host and backing up the
local x-ui database. The installation script does **not** install the Xray core
or configure an XHTTP inbound; those steps must be completed separately.

## Requirements 

- A Debian/Ubuntu server with root or `sudo` access.
- A DNS name pointed at the server before requesting a TLS certificate.
- Review of the third-party website and Nginx configuration files downloaded
  by the installer before serving them publicly.

## Nginx preparation

Run the installer as root:

```bash
sudo bash initial-install.sh
```

The script installs Nginx, Certbot, its Nginx plugin, Git, and wget. It removes
the default Nginx index page and places the tracked files from the
[restaurant website repository](https://github.com/YaninaTrekhleb/restaurant-website)
directly in `/var/www/html` (without copying its `.git` metadata). It stops if
that directory already contains other files, so review or back them up before
running the installer.

It also downloads `default_https_site_only` and `default_https` into
`/etc/nginx/sites-available`. The script does **not** enable either site or
restart Nginx. Review both files and select only the configuration appropriate
for your server. After enabling your chosen configuration, validate and reload
Nginx:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Once DNS and the selected Nginx site are ready, request a certificate for your
own domain (replace the example domain):

```bash
sudo certbot --nginx -d example.com
```

## Local database backup

[backup.sh](./backup.sh) copies `/etc/x-ui/x-ui.db` into a dated folder under
`/root/backups/`, named `xray-backup-YYYY-MM-DD`. It also removes old matching
backup folders using `find -mtime +1`; because `find` rounds ages in 24-hour
periods, this generally matches folders at least two days old, not exactly one
day old.

Run it manually as root:

```bash
sudo bash backup.sh
```

To run it daily at 23:59, install the script at the path used by the cron
entry and make it executable:

```bash
sudo install -m 700 backup.sh /usr/local/bin/backup.sh
sudo crontab -e
```

Add this line to root's crontab:

```cron
59 23 * * * /usr/local/bin/backup.sh
```

## Remote backup

[backup-rsync.sh](./backup-rsync.sh) makes the same local database backup,
waits for a short random interval, then attempts to sync it to a remote host
over SSH/rsync and remove old remote backup folders.

Before using it:

1. Install `rsync` and configure SSH key authentication from the server to the
   remote host.
2. Replace `<REMOTE_USER>`, `<REMOTE_HOST>`, and `<REMOTE_BACKUP_DIR>` in the
   script with the remote account, host, and destination directory.
3. Ensure the remote account can write to that directory and run the `find`
   command there.
4. Run `sudo bash backup-rsync.sh` and verify the backup exists on the remote
   host.

The backup scripts cover only `/etc/x-ui/x-ui.db`; they do not back up Xray
configuration, Nginx site files, TLS certificates, or other server data.
Maintain separate backups of anything needed for a full server restore.
