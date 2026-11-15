#!/usr/bin/env bash
set -Eeuo pipefail

uid="$(id -u)"
runtime="/run/user/$uid"

if pgrep -u "$uid" -x sway >/dev/null 2>&1; then
  printf 'Sway is already running on %s.\n' "$(hostname)"
  exit 0
fi

[[ -d "$runtime" ]] || { printf 'Missing %s\n' "$runtime" >&2; exit 1; }
[[ -S "$runtime/bus" ]] || { printf 'Missing %s/bus\n' "$runtime" >&2; exit 1; }

# Allocate a real VT, switch to it, and run Sway directly as joel.  No su,
# display manager, PAM service, transient systemd service, or synthetic login.
exec /run/wrappers/bin/sudo \
  /run/current-system/sw/bin/openvt \
  --switch \
  --force \
  --wait \
  -- \
  /run/wrappers/bin/sudo \
  --preserve-env=HOME,USER,LOGNAME,SHELL,PATH,XDG_RUNTIME_DIR,DBUS_SESSION_BUS_ADDRESS \
  --user=joel \
  /run/current-system/sw/bin/env \
  XDG_RUNTIME_DIR="$runtime" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime/bus" \
  /run/current-system/sw/bin/sway
