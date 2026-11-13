#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root (for example: sudo bash initial-install.sh)." >&2
    exit 1
fi

apt-get update
apt-get install -y nginx certbot python3-certbot-nginx git wget

WEB_ROOT="/var/www/html"
NGINX_SITES="/etc/nginx/sites-available"
if [[ ! -d "$WEB_ROOT" || ! -d "$NGINX_SITES" ]]; then
    echo "ERROR: Expected Nginx directories are missing after installation." >&2
    exit 1
fi

if [[ -n "$(find "$WEB_ROOT" -mindepth 1 -maxdepth 1 ! -name index.nginx-debian.html -print -quit)" ]]; then
    echo "ERROR: $WEB_ROOT is not empty; refusing to overwrite existing website files." >&2
    exit 1
fi

rm -f "$WEB_ROOT/index.nginx-debian.html"
STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT
git clone --depth 1 "https://github.com/YaninaTrekhleb/restaurant-website.git" "$STAGING_DIR/restaurant-website"
git -C "$STAGING_DIR/restaurant-website" archive HEAD | tar -x -C "$WEB_ROOT"

wget -O "$NGINX_SITES/default_https_site_only" \
    "https://raw.githubusercontent.com/filip-lebiecki/xray-xhttp/refs/heads/main/default_https_site_only"
wget -O "$NGINX_SITES/default_https" \
    "https://raw.githubusercontent.com/filip-lebiecki/xray-xhttp/refs/heads/main/default_https"

# cd /etc/nginx/sites-enabled/
# rm /etc/nginx/sites-enabled/default
# ln -s /etc/nginx/sites-available/default_https_site_only default
# ln -s /etc/nginx/sites-available/default_https default
# nginx -t
# systemctl restart nginx, systemctl reload nginx