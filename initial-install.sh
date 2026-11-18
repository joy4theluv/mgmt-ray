#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script as root (for example: sudo bash initial-install.sh)." >&2
    exit 1
fi

echo "==> Starting initial installation of Nginx and Certbot..."
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_INDEX="$SCRIPT_DIR/index.html"
LOCAL_SITE_ONLY="$SCRIPT_DIR/https-site-only"
LOCAL_WS="$SCRIPT_DIR/https-websocket"

echo "==> Checking for required files..."
for source_file in "$LOCAL_INDEX" "$LOCAL_SITE_ONLY" "$LOCAL_WS"; do
    if [[ ! -f "$source_file" ]]; then
        echo "ERROR: Required file not found: $source_file" >&2
        exit 1
    fi
done

apt-get update -y 

echo "Choose packages to install:"
echo "  1) Nginx only"
echo "  2) Nginx and Certbot"
if ! read -r -p "Enter choice [1-2]: " package_choice; then
    echo "ERROR: Could not read package selection." >&2
    exit 1
fi

case "$package_choice" in
    1)
        echo "==> Installing Nginx..."
        apt-get install -y nginx
        ;;
    2)
        echo "==> Installing Nginx and Certbot..."
        apt-get install -y nginx certbot python3-certbot-nginx
        ;;
    *)
        echo "ERROR: Invalid selection. Choose 1 or 2." >&2
        exit 1
        ;;
esac

echo "==> Checking required Nginx directories..."
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

echo "==> Installing index.html to /var/www/html/..."
install -m 644 "$LOCAL_INDEX" "$WEB_ROOT/index.html"

echo "==> Removing default Nginx index file..."
rm -f "$WEB_ROOT/index.nginx-debian.html"

echo "==> Installing Nginx site configuration files..."
install -m 644 "$LOCAL_WS" "$NGINX_SITES/https-websocket"
install -m 644 "$LOCAL_SITE_ONLY" "$NGINX_SITES/https-site-only"