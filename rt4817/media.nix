{ config, lib, pkgs, ... }:
let
  limiterLibrary = "${pkgs.ladspaPlugins}/lib/ladspa/fast_lookahead_limiter_1913.so";
  # Controls by ordinal avoid translated/case-dependent control names.
  # Input gain 0 dB, sample ceiling 0 dBFS, release 0.1 seconds.
  limiterPCM = slave: ''
    pcm.camilladsp_peak_limited {
      type plug
      slave {
        pcm "camilladsp_peak_ladspa"
        format FLOAT_LE
        channels 2
        rate 96000
      }
    }

    pcm.camilladsp_peak_ladspa {
      type ladspa
      channels 2
      slave.pcm "${slave}"
      path "${pkgs.ladspaPlugins}/lib/ladspa"
      playback_plugins {
        0 {
          filename "${limiterLibrary}"
          label "fastLookaheadLimiter"
          policy none
          input {
            bindings {
              0 "Input 1"
              1 "Input 2"
            }
            controls {
              0 0.0
              1 0.0
              2 0.1
            }
          }
          output {
            bindings {
              0 "Output 1"
              1 "Output 2"
            }
          }
        }
      }
    }
  '';
  productionPCM = ''
    # FLOAT input -> stereo-linked lookahead limiter -> integer conversion.
    pcm.camilladsp_peak_integer {
      type plug
      slave {
        pcm "hw:Loopback,0,1"
        channels 2
        rate 96000
        format S32_LE
      }
    }
  '' + limiterPCM "camilladsp_peak_integer";
  testConfig = pkgs.writeText "camilladsp-peak-limiter-test.conf" (''
    pcm.null { type null }
    pcm.camilladsp_peak_integer {
      type file
      slave.pcm "null"
      file "limited.f32"
      format "raw"
    }
  '' + limiterPCM "camilladsp_peak_integer");
  python = pkgs.python3.withPackages (ps: [ ps.numpy ]);
  # Runs against the user's selected nixpkgs at build time, with no sound device.
  # A failed plugin load or numerical test prevents this module being installed.
  testScript = pkgs.writeText "camilladsp-peak-limiter-test.py" ''
    import os, subprocess
    import numpy as np
    rate = 96000
    def process(x):
        x = np.asarray(x, dtype='<f4')
        x.tofile('input.f32')
        try: os.unlink('limited.f32')
        except FileNotFoundError: pass
        subprocess.run(['${pkgs.alsa-utils}/bin/aplay', '-q', '-D',
                        'camilladsp_peak_limited', '-t', 'raw', '-f',
                        'FLOAT_LE', '-r', str(rate), '-c', '2', 'input.f32'],
                       check=True)
        y = np.fromfile('limited.f32', dtype='<f4')
        assert y.size > 0 and y.size % 2 == 0, 'Invalid output size'
        y = y.reshape(-1, 2)
        assert np.isfinite(y).all(), 'Non-finite output'
        assert np.max(np.abs(y)) <= 1.0, 'Sample ceiling exceeded'
        return y
    # Verify CamillaDSP itself does not clamp floating-point output before ALSA.
    probe = np.zeros((4096,2), dtype='<f4')
    probe[100:200] = 4.0
    probe.tofile('engine-input.f32')
    with open('engine-test.yml','w') as f:
        f.write("devices:\n  samplerate: 96000\n  chunksize: 1024\n"
                "  capture:\n    type: RawFile\n    channels: 2\n"
                "    filename: engine-input.f32\n    format: F32_LE\n"
                "  playback:\n    type: File\n    channels: 2\n"
                "    filename: engine-output.f32\n    format: F32_LE\n"
                "pipeline: []\n")
    subprocess.run(['${pkgs.camilladsp}/bin/camilladsp','engine-test.yml'],
                   check=True, timeout=30)
    engine = np.fromfile('engine-output.f32',dtype='<f4')
    assert engine.size > 0 and np.max(engine) == 4.0, 'CamillaDSP clamps float output; cannot install this external-limiter design'
    t = np.arange(rate * 2) / rate
    low = np.column_stack((0.1*np.sin(2*np.pi*997*t),
                           0.05*np.sin(2*np.pi*997*t)))
    y = process(low)
    # A lookahead delay is expected; verify steady-state unity gain and stereo.
    assert abs(float(np.max(np.abs(y[:,0]))) - 0.1) < 0.001
    assert np.max(np.abs(y[:,1] - 0.5*y[:,0])) < 1e-5
    high = np.column_stack((8*np.sin(2*np.pi*997*t),
                            4*np.sin(2*np.pi*997*t)))
    y = process(high)
    assert np.max(np.abs(y[:,0])) > 0.8, 'Limiter output unexpectedly muted'
    # Link test during steady-state limiting, excluding startup and end padding.
    assert np.max(np.abs(y[rate//2:rate,1] - 0.5*y[rate//2:rate,0])) < 1e-4
    rng = np.random.default_rng(4817)
    burst = np.zeros((rate*2,2),dtype=np.float32)
    burst[rate//4:rate//2] = rng.uniform(-128,128,(rate//4,2))
    burst[rate,0] = 256; burst[rate+1,1] = -256
    process(burst)
    print('PASS: native ALSA plugin load, unity below ceiling, stereo linkage, '
          'over-level sine, random bursts and isolated impulses at 96 kHz.')
  '';
  tested = pkgs.runCommand "camilladsp-peak-limiter-v11-tested" {
    nativeBuildInputs = [ python pkgs.alsa-utils ];
  } ''
    test -f "${limiterLibrary}"
    export ALSA_CONFIG_PATH="${testConfig}"
    python "${testScript}" > report.txt
    mkdir -p "$out"
    cp report.txt "$out/report.txt"
  '';
in {

  environment.systemPackages = [ pkgs.ladspaPlugins pkgs.alsa-utils ];
  environment.etc."camilladsp-peak-limiter-v11".source = "${tested}/report.txt";

  # Audio (PipeWire + WirePlumber)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  security.rtkit.enable = true;

  systemd.timers.audio-fixes = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "10s";
    };
  };

  systemd.services.audio-fixes = {
    description = "Maintain ALSA audio switches";
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
      done
    '';
  };

  environment.etc."asound.conf".text = ''
    ${productionPCM}
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
        volume_control_profile = "dasl_tapered";
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
