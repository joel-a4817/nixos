{ config, lib, pkgs, ... }:

{
  services.snapserver = {
    enable = true;
    openFirewall = true;

    settings = {
      stream = {
        source = "pipe:///run/snapserver/ash-iphone?name=ASH_iPhone&sampleformat=96000:16:2&codec=flac&chunk_ms=20";
        buffer = 1000;
      };

      http = {
        enabled = true;
      };

      tcp-control = {
        enabled = true;
      };

      tcp-streaming = {
        enabled = true;
      };
    };
  };

  services.shairport-sync = {
    enable = true;
    package = pkgs.shairport-sync-airplay2;
    user = "joel";
    group = "users";
    #openFirewall = true; -> doesn't work for airplay2
    settings = {
      general = {
        name = "rt4817";
        service_type = "airplay2";
        output_backend = "pipewire";
        default_airplay_volume = -12.0;
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
