{ config, lib, pkgs, ... }:

{
  security.rtkit.enable = true;

  systemd.timers.audio-fixes = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "10s";
    };
  };

  systemd.services.audio-fixes = {
    description = "Neutralize ALSA capture gains";
    wantedBy = [ "multi-user.target" ];
    after = [ "sound.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      sleep 5

      for card in $(seq 0 20); do
        ${pkgs.alsa-utils}/bin/amixer \
          -c "$card" \
          sset "Auto-Mute Mode" Disabled \
          >/dev/null 2>&1 || true

        ${pkgs.alsa-utils}/bin/amixer \
          -c "$card" \
          set Capture cap \
          >/dev/null 2>&1 || true

        ${pkgs.alsa-utils}/bin/amixer \
          -c "$card" \
          scontrols \
          2>/dev/null |
        sed -n \
          "s/^Simple mixer control '\(.*\)',0$/\1/p" |
        grep -Ei \
          "capture|mic" |
        while IFS= read -r ctl; do
          ${pkgs.alsa-utils}/bin/amixer \
            -c "$card" \
            set "$ctl" 0dB \
            >/dev/null 2>&1 || true
        done
      done
    '';
  };

  environment.etc."asound.conf".text = ''
    #
    # Shared input into CamillaDSP.
    #
    # Multiple clients can write here:
    #   - PipeWire system audio
    #   - Shairport Sync
    #   - mpv PC Music
    #
    # CamillaDSP captures the paired endpoint:
    #   hw:Loopback,1,0
    #
    pcm.camilladsp_input {
      type dmix
      ipc_key 481700
      ipc_key_add_uid true

      slave {
        pcm "hw:Loopback,0,0"
        channels 2
        rate 96000
        format S32_LE
        period_size 1024
        buffer_size 4096
      }

      bindings {
        0 0
        1 1
      }

      hint {
        show on
        description "CamillaDSP Shared Input"
      }
    }

    #
    # CamillaDSP output exposed to SonoBus.
    #
    # CamillaDSP writes to:
    #   hw:Loopback,0,1
    #
    # SonoBus reads the paired endpoint:
    #   hw:Loopback,1,1
    #
    pcm.sonobus_camilladsp {
      type plug

      slave {
        pcm "hw:Loopback,1,1"
        channels 2
        rate 96000
        format S32_LE
      }

      hint {
        show on
        description "CamillaDSP SonoBus"
      }
    }

    pcm.sonobus_silent {
      type null

      hint {
        show on
        description "SonoBus Silent Output"
      }
    }
  '';

  systemd.user.services.playerctld = {
    description = "Track the most recently active MPRIS player";
    wantedBy = [ "default.target" ];

    unitConfig.ConditionUser = "joel";

    serviceConfig = {
      Type = "simple";
      ExecStart =
        "${pkgs.playerctl}/bin/playerctld daemon";

      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  systemd.user.services.camilladsp-system-audio = {
    description =
      "Route desktop audio into CamillaDSP";

    wantedBy = [ "default.target" ];

    after = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];

    wants = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];

    unitConfig.ConditionUser = "joel";

    path = with pkgs; [
      bash
      coreutils
      gawk
      gnugrep
      pulseaudio
    ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "2s";

      ExecStart = "${pkgs.writeShellScript "camilladsp-system-audio" ''
        set -euo pipefail

        for _ in $(seq 1 100); do
          if pactl info >/dev/null 2>&1; then
            break
          fi

          sleep 0.1
        done

        pactl info >/dev/null

        existing="$(
          pactl list short modules |
          awk '
            $2 == "module-alsa-sink" &&
            $0 ~ /sink_name=camilladsp/ {
              print $1
            }
          '
        )"

        if [[ -n "$existing" ]]; then
          while IFS= read -r module_id; do
            if [[ -n "$module_id" ]]; then
              pactl unload-module \
                "$module_id" \
                2>/dev/null || true
            fi
          done <<< "$existing"
        fi

        MODULE_ID="$(
          pactl load-module \
            module-alsa-sink \
            device=camilladsp_input \
            sink_name=camilladsp \
            sink_properties=device.description=CamillaDSP_System_Audio \
            rate=96000 \
            channels=2
        )"

        cleanup() {
          pactl unload-module \
            "$MODULE_ID" \
            2>/dev/null || true
        }

        trap cleanup EXIT INT TERM

        pactl set-default-sink \
          camilladsp

        #
        # Move currently playing applications to the new sink.
        #
        pactl list short sink-inputs |
        cut -f1 |
        while IFS= read -r input_id; do
          if [[ -n "$input_id" ]]; then
            pactl move-sink-input \
              "$input_id" \
              camilladsp \
              2>/dev/null || true
          fi
        done

        while sleep 10; do
          pactl list short sinks |
          grep -q $'\tcamilladsp\t'

          current_default="$(
            pactl get-default-sink
          )"

          if [[ "$current_default" != "camilladsp" ]]; then
            pactl set-default-sink \
              camilladsp
          fi
        done
      ''}";
    };
  };

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
      };

      alsa = {
        output_device = "camilladsp_input";
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

    environment = {
      HOME = "/home/joel";
      XDG_RUNTIME_DIR = "/run/user/1000";
      PIPEWIRE_RUNTIME_DIR = "/run/user/1000";
    };

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
