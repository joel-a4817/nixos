{ config, lib, pkgs, ... }:
{
  services.resolved.enable = true;
  services.usbmuxd.enable = true;

  networking.networkmanager = {
    enable = true;

    ensureProfiles = {
      environmentFiles = [
        "/home/joel/Documents/prefs/airplay-hotspot.env"
      ];

      profiles."airplay-direct" = {
        connection = {
          id = "AirPlay Direct";
          type = "wifi";
          autoconnect = false;
          permissions = "";
        };

        wifi = {
          mode = "ap";
          ssid = "Joel AirPlay";
        };

        wifi-security = {
          # WPA2-Personal only.
          key-mgmt = "wpa-psk";
          proto = "rsn";

          # AES-CCMP only. Do not permit TKIP.
          pairwise = "ccmp";
          group = "ccmp";

          psk = "$AIRPLAY_HOTSPOT_PASSWORD";
        };

        ipv4 = {
          # NetworkManager provides local addressing, DHCP and NAT.
          method = "shared";
        };

        ipv6 = {
          method = "disabled";
        };
      };
    };
  };

  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      3689
      5000
      7000 #airplay
      8384 #syncthing
      22000
    ];

    allowedTCPPortRanges = [
      {
        from = 32768;
        to = 60999;
      }
    ];

    allowedUDPPorts = [
      319 #nqptp
      320 #nqptp
      5353
      22000
      21027
    ];

    allowedUDPPortRanges = [
      {
        from = 6000;
        to = 6009;
      }
      {
        from = 32768;
        to = 60999;
      }
    ];
  };

  services.tailscale.enable = true;
  systemd.user.services.camilladsp-wayvnc = {
    description =
      "WayVNC for the existing Sway session";

    after = [
      "graphical-session.target"
    ];

    partOf = [
      "graphical-session.target"
    ];

    wantedBy = [
      "graphical-session.target"
    ];

    unitConfig.ConditionUser = "joel";

    path = with pkgs; [
      bash
      coreutils
      tailscale
      wayvnc
    ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "2s";

      ExecStart = "${pkgs.writeShellScript "camilladsp-wayvnc" ''
        set -euo pipefail

        export XDG_RUNTIME_DIR="/run/user/$(id -u)"

        WAYLAND_SOCKET=""

        for _ in $(seq 1 50); do
          for socket in \
            "$XDG_RUNTIME_DIR"/wayland-*;
          do
            [[ -S "$socket" ]] || continue

            WAYLAND_SOCKET="$socket"
            break
          done

          [[ -n "$WAYLAND_SOCKET" ]] &&
            break

          sleep 0.2
        done

        if [[ -z "$WAYLAND_SOCKET" ]]; then
          echo \
            "No running Sway Wayland socket found" \
            >&2

          exit 1
        fi

        export WAYLAND_DISPLAY="$(
          basename "$WAYLAND_SOCKET"
        )"

        VNC_ADDRESS=""

        for _ in $(seq 1 30); do
          VNC_ADDRESS="$(
            tailscale ip -4 \
              2>/dev/null |
            head -n 1
          )"

          [[ -n "$VNC_ADDRESS" ]] &&
            break

          sleep 1
        done

        if [[ -z "$VNC_ADDRESS" ]]; then
          echo \
            "No Tailscale IPv4 address available" \
            >&2

          exit 1
        fi

        exec wayvnc \
          --max-fps=30 \
          "$VNC_ADDRESS" \
          5901
      ''}";
    };
  };

  services.shairport-sync = {
    enable = true;
    package = pkgs.shairport-sync-airplay2;

    user = "joel";
    group = "users";

    arguments = "-vvv";

    settings = {
      general = {
        name = "rt4817";
        service_type = "airplay2";
        output_backend = "alsa";
        default_airplay_volume = 0.0;
        volume_control_profile = "dasl_tapered";
      };

      alsa = {
        output_device = "default";
        output_rate = 96000;
        output_format = "S32_LE";
        output_channels = 2;
      };
    };
  };

  systemd.services.nqptp = {
    description =
      "NQPTP AirPlay 2 Timing Daemon";

    wantedBy = [
      "multi-user.target"
    ];

    before = [
      "shairport-sync.service"
    ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.nqptp}/bin/nqptp";

      Restart = "on-failure";
      RestartSec = 1;

      AmbientCapabilities = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
      ];

      CapabilityBoundingSet = [
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
      ];
    };
  };

  systemd.services.shairport-sync = {
    after = [
      "nqptp.service"
      "user@1000.service"
    ];

    requires = [
      "nqptp.service"
    ];

    wants = [
      "user@1000.service"
    ];


    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
