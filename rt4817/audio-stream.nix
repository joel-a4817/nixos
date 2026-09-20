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

  environment.etc."shairport-sync.conf" = {
    mode = "0644";

    text = ''
      general = {
        name = "rt4817";

        // Route through pipewire-pulse rather than Shairport's
        // native PipeWire backend.
        output_backend = "pa";

        // High-quality correction for clock drift.
        interpolation = "soxr";

        // Give the desktop audio server more buffering headroom.
        audio_backend_buffer_desired_length_in_seconds = 0.5;
        audio_backend_buffer_interpolation_threshold_in_seconds = 0.1;

        // Respect volume changes from the iPad.
        ignore_volume_control = "no";

        // Disconnect cleanly when the sender disappears.
        session_timeout = 20;
      };

      metadata = {
        enabled = "yes";
        include_cover_art = "yes";
      };
    '';
  };

  systemd.services.nqptp = {
    description = "Not Quite PTP for AirPlay 2";

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
    description = "Shairport Sync AirPlay 2 Receiver";

    wantedBy = [
      "multi-user.target"
    ];

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

      // Ensure the PulseAudio compatibility client reaches
      // Joel's pipewire-pulse socket.
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
    };

    serviceConfig = {
      User = "joel";
      Group = "users";

      ExecStart = ''
        ${pkgs.shairport-sync-airplay2}/bin/shairport-sync \
          -c /etc/shairport-sync.conf
      '';

      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
