#!/usr/bin/env bash
set -Eeuo pipefail

unit='sway-remote.service'
uid="$(id -u)"
runtime="/run/user/$uid"
bus="$runtime/bus"
host="$(hostname)"

export XDG_RUNTIME_DIR="$runtime"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$bus"
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

if [[ ! -d "$runtime" || ! -S "$bus" ]]; then
  printf 'User systemd/DBus session is unavailable at %s.\n' "$runtime" >&2
  printf 'Check: loginctl user-status %s\n' "$USER" >&2
  exit 1
fi

if pgrep -u "$uid" -x sway >/dev/null; then
  printf 'Sway is already running on %s.\n' "$host"
  exit 0
fi

# Clear only the transient launcher unit. This does not make Sway autostart.
systemctl --user stop "$unit" >/dev/null 2>&1 || true
systemctl --user reset-failed "$unit" >/dev/null 2>&1 || true

sway_bin="$(command -v sway)"

systemd-run --user \
  --unit="${unit%.service}" \
  --collect \
  --quiet \
  --property=Type=exec \
  --property=Restart=no \
  --property=StandardInput=null \
  --property=StandardOutput=journal \
  --property=StandardError=journal \
  --setenv=XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  --setenv=DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS" \
  --setenv=XDG_SESSION_TYPE="$XDG_SESSION_TYPE" \
  --setenv=XDG_SESSION_DESKTOP="$XDG_SESSION_DESKTOP" \
  --setenv=XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" \
  -- "$sway_bin"

for _ in $(seq 1 50); do
  if pgrep -u "$uid" -x sway >/dev/null; then
    printf 'Sway started on %s.\n' "$host"
    exit 0
  fi

  state="$(systemctl --user show "$unit" --property=ActiveState --value 2>/dev/null || true)"
  if [[ "$state" == failed || "$state" == inactive ]]; then
    printf 'Sway failed to start on %s. Recent log:\n' "$host" >&2
    journalctl --user --unit="$unit" --lines=60 --no-pager >&2
    exit 1
  fi
  sleep 0.2
done

printf 'Sway launch timed out on %s. Recent log:\n' "$host" >&2
journalctl --user --unit="$unit" --lines=60 --no-pager >&2
exit 1
