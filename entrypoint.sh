#!/bin/bash
set -e

# Start hostapd + dnsmasq if available
if [ -f /etc/init.d/hostapd ]; then
    echo "Starting hostapd..."
    service hostapd start || true
fi

if [ -f /etc/init.d/dnsmasq ]; then
    echo "Starting dnsmasq..."
    service dnsmasq start || true
fi

# Launch Pi-Pwn’s web or CLI (adjust if different)
echo "Launching Pi-Pwn..."
cd /opt/pi-pwn

# If Pi-Pwn uses a Python web server (common)
python3 app.py
