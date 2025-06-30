#!/bin/bash
set -euo pipefail

# Continually establish the AnyConnect VPN and ensure the SOCKS5 proxy stays
# available.  If the VPN connection drops for any reason, dependent
# processes (openconnect & danted) will be restarted automatically.

start_vpn() {
  local pidfile=/var/run/openconnect.pid
  rm -f "$pidfile"
  if [[ -z "${CERT:-}" ]]; then
    printf '%s\n' "$ANYCONNECT_PASSWORD" | \
      openconnect "$ANYCONNECT_SERVER" \
        --user="$ANYCONNECT_USER" \
        --passwd-on-stdin \
        --no-dtls \
        --timestamp \
        --background \
        --pid-file="$pidfile"
  else
    printf '%s\n' "$ANYCONNECT_PASSWORD" | \
      openconnect "$ANYCONNECT_SERVER" \
        --user="$ANYCONNECT_USER" \
        --servercert="$CERT" \
        --passwd-on-stdin \
        --no-dtls \
        --timestamp \
        --background \
        --pid-file="$pidfile"
  fi

  # Give openconnect up to 5 seconds to write its pidfile
  for _ in {1..5}; do
    [[ -f "$pidfile" ]] && break || sleep 1
  done
  if [[ ! -f "$pidfile" ]]; then
    echo "Failed to obtain openconnect PID. Will retry connection."
    return 1
  fi
  VPN_PID=$(cat "$pidfile")
}

wait_for_tunnel() {
  echo "Waiting for tun0 interface to appear..."
  local retries=0
  until ip link show tun0 &>/dev/null; do
    sleep 2
    ((retries++))
    if (( retries % 15 == 0 )); then
      echo "Still waiting for tun0 after $((retries*2))s..."
    fi
  done
  echo "Tunnel interface tun0 is up."
}

start_dante() {
  /usr/sbin/danted -f /etc/danted.conf -D &
  DANTE_PID=$!
  echo "Started Dante SOCKS5 server (pid=$DANTE_PID)."
}

cleanup_children() {
  echo "Cleaning up child processes..."
  [[ -n "${DANTE_PID:-}" ]] && kill "$DANTE_PID" 2>/dev/null || true
  # Ensure tun0 is removed to avoid stale interface issues on reconnect
  ip link del tun0 2>/dev/null || true
}

# Handle SIGTERM/SIGINT so Docker can stop the container cleanly
trap 'echo "Received termination signal"; cleanup_children; exit 0' SIGINT SIGTERM

while true; do
  if ! start_vpn; then
    echo "VPN start failed – retrying in 5 seconds..."
    sleep 5
    continue
  fi
  wait_for_tunnel
  start_dante

  echo "All services started. Monitoring VPN process (pid=$VPN_PID)..."
  wait "$VPN_PID" || true
  echo "VPN process exited with status $? – restarting in 5 seconds."

  cleanup_children
  sleep 5
done
