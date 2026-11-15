#!/usr/bin/env bash
set -Eeuo pipefail

uid="$(id -u)"

if pgrep -u "$uid" -x sway >/dev/null 2>&1; then
  printf 'Sway is already running on %s.\n' "$(hostname)"
  exit 0
fi

# An SSH shell owns /dev/pts/*, not a real Linux VT.  Ask root's openvt to
# allocate and activate a free VT, then the generated sway-on-vt helper drops
# straight back to joel before starting Sway.
/run/wrappers/bin/sudo /run/current-system/sw/bin/openvt --switch -- "$SWAY_ON_VT"

for _ in $(seq 1 50); do
  if pgrep -u "$uid" -x sway >/dev/null 2>&1; then
    printf 'Sway started on %s.\n' "$(hostname)"
    exit 0
  fi
  sleep 0.1
done

printf 'Sway did not remain running. Check the local VT or run: journalctl -b -t sway-remote\n' >&2
exit 1
