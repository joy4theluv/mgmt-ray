#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root (for example: sudo bash initial-install.sh)." >&2
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_INDEX="$SCRIPT_DIR/index.html"
LOCAL_SITE_ONLY="$SCRIPT_DIR/https_site_only"
LOCAL_XHTTP="$SCRIPT_DIR/https_xhttp"

for source_file in "$LOCAL_INDEX" "$LOCAL_SITE_ONLY" "$LOCAL_XHTTP"; do
    if [[ ! -f "$source_file" ]]; then
        echo "ERROR: Required file not found: $source_file" >&2
        exit 1
    fi
done

apt-get update -y

apt-get install -y nginx certbot python3-certbot-nginx

WEB_ROOT="/var/www/html"
NGINX_SITES="/etc/nginx/sites-available"
if [[ ! -d "$WEB_ROOT" ]]; then
    echo "ERROR: Nginx did not create $WEB_ROOT after installation." >&2
    exit 1
fi
if [[ ! -d "$NGINX_SITES" ]]; then
    echo "ERROR: Expected Nginx directories are missing after installation." >&2
    exit 1
fi

install -m 644 "$LOCAL_INDEX" "$WEB_ROOT/index.html"
rm -f "$WEB_ROOT/index.nginx-debian.html"
install -m 644 "$LOCAL_XHTTP" "$NGINX_SITES/https_xhttp"
install -m 644 "$LOCAL_SITE_ONLY" "$NGINX_SITES/https_site_only"