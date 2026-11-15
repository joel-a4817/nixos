#!/usr/bin/env bash
set -Eeuo pipefail

uid="$(id -u)"

if pgrep -u "$uid" -x sway >/dev/null 2>&1; then
  printf 'Sway is already running on %s.\n' "$(hostname)"
  exit 0
fi

# Allocate and switch to a real VT. Do not wait for the graphical session to
# exit: the SSH command should return after successful startup, and a normal
# Sway exit must not be reported as a launcher error.
/run/wrappers/bin/sudo /run/current-system/sw/bin/openvt \
  --switch \
  -- \
  "$SWAY_ON_VT"

for _ in $(seq 1 100); do
  if pgrep -u "$uid" -x sway >/dev/null 2>&1; then
    printf 'Sway started on %s.\n' "$(hostname)"
    exit 0
  fi
  sleep 0.1
done

printf 'Sway failed during startup. Check the active VT for its error output.\n' >&2
exit 1
