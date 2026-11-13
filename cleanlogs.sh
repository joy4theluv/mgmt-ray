#!/bin/bash
# Safe log cleanup for Ubuntu VPS

# Truncate common large logs
sudo truncate -s 0 /var/log/syslog
sudo truncate -s 0 /var/log/kern.log
sudo truncate -s 0 /var/log/auth.log

# Clean apt cache
sudo apt-get clean

# Shrink systemd journal to 200MB
sudo journalctl --vacuum-size=200M

# Force logrotate to rotate logs immediately
sudo logrotate -f /etc/logrotate.conf

echo "✅ Logs cleaned safely. System should keep running fine."
