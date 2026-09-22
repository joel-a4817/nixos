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
        ${pkgs.alsa-utils}/bin/amixer -c "$card" \
          sset 'Auto-Mute Mode' Disabled >/dev/null 2>&1 || true
        ${pkgs.alsa-utils}/bin/amixer -c "$card" \
          set Capture cap >/dev/null 2>&1 || true
        ${pkgs.alsa-utils}/bin/amixer -c "$card" scontrols 2>/dev/null |
        sed -n "s/^Simple mixer control '\(.*\)',0$/\1/p" |
        grep -Ei 'capture|mic' |
        while IFS= read -r ctl; do
          ${pkgs.alsa-utils}/bin/amixer -c "$card" \
            set "$ctl" 0dB >/dev/null 2>&1 || true
        done
      done
    '';
  };

  environment.etc."asound.conf".text = ''
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

  services.shairport-sync = {
    enable = true;
    package = pkgs.shairport-sync-airplay2;
    user = "joel";
    group = "users";
    # openFirewall = true; # Doesn't currently cover AirPlay 2 correctly
    arguments = "-vvv";
    settings = {
      general = {
        name = "rt4817";
        service_type = "airplay2";
        output_backend = "alsa";
        default_airplay_volume = -12.0;
      };
      alsa = {
        output_device = "hw:Loopback,0,0";
        output_rate = 96000;
        output_format = "S32_LE";
        output_channels = 2;
      };
    };
  };

  systemd.services.nqptp = {
    description = "NQPTP AirPlay 2 Timing Daemon";

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
