#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

log() { printf '[entrypoint] %s\n' "$*"; }

# Configurable behavior via env vars
: "${START_DNSMASQ:=false}"   # set to "true" to try start dnsmasq
: "${START_HOSTAPD:=false}"   # set to "true" to try start hostapd
: "${START_CMD:=}"            # override what starts the pi-pwn app (e.g. "python3 server.py" or "./start.sh")

log "Environment: START_DNSMASQ=${START_DNSMASQ}, START_HOSTAPD=${START_HOSTAPD}, START_CMD='${START_CMD}'"

# helper: check if TCP/UDP port is in use (works inside container/host network namespace)
port_in_use() {
  local p=$1
  # prefer ss, fallback to netstat if available
  if command -v ss >/dev/null 2>&1; then
    ss -ltnp 2>/dev/null | awk '{print $4}' | grep -q -E "[:.]${p}$" && return 0 || return 1
  elif command -v netstat >/dev/null 2>&1; then
    netstat -ltnp 2>/dev/null | awk '{print $4}' | grep -q -E "[:.]${p}$" && return 0 || return 1
  else
    return 1
  fi
}

# Start dnsmasq (best-effort)
if [[ "${START_DNSMASQ}" == "true" ]]; then
  if port_in_use 53; then
    log "Port 53 is already in use in this network namespace. Will NOT start dnsmasq to avoid conflict."
  else
    if command -v dnsmasq >/dev/null 2>&1; then
      log "Launching dnsmasq in foreground (logs -> /var/log/dnsmasq.log)"
      # run dnsmasq in background, but don't try to manage system services
      dnsmasq --no-daemon &>/var/log/dnsmasq.log &
      sleep 0.5
      if port_in_use 53; then
        log "dnsmasq appears to be running and bound to port 53."
      else
        log "dnsmasq started but did not bind port 53; check /var/log/dnsmasq.log"
      fi
    else
      log "dnsmasq binary not found. Skipping."
    fi
  fi
else
  log "START_DNSMASQ != true — skipping dnsmasq startup."
fi

# Start hostapd (best-effort)
if [[ "${START_HOSTAPD}" == "true" ]]; then
  if [[ -f /etc/hostapd/hostapd.conf ]]; then
    if command -v hostapd >/dev/null 2>&1; then
      log "Starting hostapd with /etc/hostapd/hostapd.conf (background)."
      hostapd /etc/hostapd/hostapd.conf &>/var/log/hostapd.log &
      sleep 0.5
    else
      log "hostapd not installed in container."
    fi
  else
    log "hostapd config /etc/hostapd/hostapd.conf not found — skipping hostapd."
  fi
else
  log "START_HOSTAPD != true — skipping hostapd startup."
fi

# Show interfaces (helpful diagnostics)
log "Network interfaces (ip link):"
ip -br link || true
log "IP addresses (ip addr):"
ip -br addr || true

# Attempt to launch Pi-Pwn app
cd /opt/pi-pwn || true

# If an explicit START_CMD provided, run that
if [[ -n "${START_CMD}" ]]; then
  log "Starting user-provided START_CMD: ${START_CMD}"
  exec /bin/bash -lc "${START_CMD}"
fi

# Detect common entrypoints
candidates=(app.py pi_pwn.py run.py server.py start.sh run.sh pi-pwn.sh)
for f in "${candidates[@]}"; do
  if [[ -x "./$f" || -f "./$f" ]]; then
    if [[ "$f" == *.py ]]; then
      log "Found python entrypoint: $f — running python3 $f"
      exec python3 "./$f"
    else
      log "Found executable entrypoint: $f — running ./$(basename "$f")"
      exec /bin/bash -lc "./$f"
    fi
  fi
done

# No launcher found — print listing and drop to shell
log "No known launchers found in /opt/pi-pwn."
log "Listing /opt/pi-pwn (first 200 entries):"
ls -la /opt/pi-pwn | sed -n '1,200p' || true

log "You can set START_CMD env to override default launch command (e.g. START_CMD='python3 server.py')."
log "Dropping to interactive shell so you can start Pi-Pwn manually."
exec /bin/bash
