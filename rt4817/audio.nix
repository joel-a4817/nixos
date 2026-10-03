{ config, lib, pkgs, ... }:

{
  hardware.alsa.enable = true;
  hardware.alsa.config = ''
    #
    # Shared input into CamillaDSP.
    #
    # Multiple clients can write here:
    #   - ALSA desktop audio
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

    pcm.studio_master {
      type softvol
      slave.pcm "camilladsp_input"
      control { name "Studio Master" card "Loopback" }
      min_dB -60.0
      max_dB 0.0
      resolution 256
    }
    pcm.!default { type plug slave.pcm "studio_master" }

    #
    # CamillaDSP output exposed to SonoBus.
    #
    # CamillaDSP writes to:
    #   hw:Loopback,0,1
    #
    # SonoBus reads the paired endpoint:
    #   hw:Loopback,1,1
    #
    # Both SonoBus and the laptop monitor read the processed output.
    # dsnoop is the shared capture side of hw:Loopback,1,1.
    pcm.camilladsp_output_shared {
      type dsnoop
      ipc_key 481701
      ipc_key_add_uid true
      slave {
        pcm "hw:Loopback,1,1"
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
        description "CamillaDSP Shared Output Capture"
      }
    }
    pcm.sonobus_camilladsp {
      type plug
      slave {
        pcm "camilladsp_output_shared"
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

}
