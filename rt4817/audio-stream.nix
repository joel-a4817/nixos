{ config, lib, pkgs, ... }:

{
  services.snapserver = {
    enable = true;
    openFirewall = true;

    settings = {
      stream.source =
        "pipe:///run/snapserver/pipe?name=Convolved-Audio&auto_connect=false";

      tcp-streaming = {
        enabled = true;
        bind_to_address = "0.0.0.0";
        port = 1704;
      };

      tcp-control = {
        enabled = true;
        bind_to_address = "0.0.0.0";
        port = 1705;
      };

      http = {
        enabled = true;
        bind_to_address = "0.0.0.0";
        port = 1780;
      };
    };
  };

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
