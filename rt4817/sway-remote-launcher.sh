#!/usr/bin/env bash
set -Eeuo pipefail

uid="$(id -u)"
runtime="/run/user/$uid"

if pid="$(pgrep -xo -u "$uid" sway 2>/dev/null)"; then
  tty="$(ps -o tty= -p "$pid" | xargs)"
  if [[ "$tty" =~ ^tty([0-9]+)$ ]]; then
    exec /run/wrappers/bin/sudo /run/current-system/sw/bin/chvt "${BASH_REMATCH[1]}"
  fi
  printf 'Sway is already running (PID %s), but its VT is not detectable (%s).\n' "$pid" "${tty:-none}" >&2
  exit 1
fi

[[ -d "$runtime" ]] || { printf 'Missing %s\n' "$runtime" >&2; exit 1; }
[[ -O "$runtime" ]] || { printf '%s is not owned by uid %s\n' "$runtime" "$uid" >&2; exit 1; }
[[ -S "$runtime/bus" ]] || { printf 'Missing user D-Bus socket: %s/bus\n' "$runtime" >&2; exit 1; }

previous_vt="$(/run/wrappers/bin/sudo /run/current-system/sw/bin/fgconsole)"
restore_vt() {
  /run/wrappers/bin/sudo /run/current-system/sw/bin/chvt "$previous_vt" >/dev/null 2>&1 || true
}
trap restore_vt EXIT HUP INT TERM

/run/wrappers/bin/sudo /run/current-system/sw/bin/openvt \
  --switch \
  --force \
  --wait \
  -- \
  "$SWAY_VT_SESSION"
