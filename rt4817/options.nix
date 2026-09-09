{ config, lib, pkgs, ... }:

let
  ladspa-bs2b = pkgs.callPackage ./ladspa-bs2b.nix {};
  sofaFile = "${pkgs.libmysofa}/share/libmysofa/MIT_KEMAR_normal_pinna.sofa";
in
{
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  systemd.timers.audio-fixes = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "10s";
    };
  };

  systemd.services.audio-fixes = {
    description = "Normalize ALSA capture gains";
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

  # Audio (PipeWire + WirePlumber)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraLadspaPackages = [
      ladspa-bs2b
    ];
    extraConfig.pipewire."89-earpods-fir" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "EarPods FIR";

          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                label = "convolver";
                name = "left";

                config = {
                  filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                  channel = 0;
                };
              }

              {
                type = "builtin";
                label = "convolver";
                name = "right";

                config = {
                  filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                  channel = 1;
                };
              }
            ];

            inputs = [
              "left:In"
              "right:In"
            ];

            outputs = [
              "left:Out"
              "right:Out"
            ];
          };

            "capture.props" = {
              "node.name" = "earpods_fir";
              "node.description" = "EarPods FIR";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."90-cloud3-fir" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "Cloud III FIR";
          "filter.graph" = {
            nodes = [
              {
                type = "builtin";
                label = "convolver";
                name = "left";

                config = {
                  filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                  channel = 0;
                };
              }

              {
                type = "builtin";
                label = "convolver";
                name = "right";

                config = {
                  filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                  channel = 1;
                };
              }
            ];

            inputs = [
              "left:In"
              "right:In"
            ];

            outputs = [
              "left:Out"
              "right:Out"
            ];
          };
            "capture.props" = {
              "node.name" = "cloud3_fir";
              "node.description" = "Cloud III FIR";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."91-bs2b" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "BS2B";

            "filter.graph" = {
              nodes = [
                {
                  type = "ladspa";
                  plugin = "bs2b";
                  label = "bs2b";
                  name = "crossfeed";

                  control = {
                    fcut = 700.0;
                    feed = 4.5;
                  };
                }
              ];

              inputs = [
                "crossfeed:Input left"
                "crossfeed:Input right"
              ];

              outputs = [
                "crossfeed:Output left"
                "crossfeed:Output right"
              ];
            };

            "capture.props" = {
              "node.name" = "bs2b";
              "node.description" = "BS2B";
              "media.class" = "Audio/Sink";
            };
          };
        }
      ];
    };
    extraConfig.pipewire."92-earpods-fir-bs2b" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "EarPods FIR + BS2B";

            "filter.graph" = {
              nodes = [
                {
                  type = "builtin";
                  label = "convolver";
                  name = "left";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "right";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                    channel = 1;
                  };
                }

                {
                  type = "ladspa";
                  plugin = "bs2b";
                  label = "bs2b";
                  name = "crossfeed";

                  control = {
                    fcut = 700.0;
                    feed = 4.5;
                  };
                }
              ];

              inputs = [
                "left:In"
                "right:In"
              ];

              outputs = [
                "crossfeed:Output left"
                "crossfeed:Output right"
              ];

              links = [
                {
                  output = "left:Out";
                  input = "crossfeed:Input left";
                }

                {
                  output = "right:Out";
                  input = "crossfeed:Input right";
                }
              ];
            };

            "capture.props" = {
              "node.name" = "earpods_fir_bs2b";
              "node.description" = "EarPods FIR + BS2B";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."93-cloud3-fir-bs2b" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "Cloud III FIR + BS2B";

            "filter.graph" = {
              nodes = [
                {
                  type = "builtin";
                  label = "convolver";
                  name = "left";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "right";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                    channel = 1;
                  };
                }

                {
                  type = "ladspa";
                  plugin = "bs2b";
                  label = "bs2b";
                  name = "crossfeed";

                  control = {
                    fcut = 700.0;
                    feed = 4.5;
                  };
                }
              ];

              inputs = [
                "left:In"
                "right:In"
              ];

              outputs = [
                "crossfeed:Output left"
                "crossfeed:Output right"
              ];

              links = [
                {
                  output = "left:Out";
                  input = "crossfeed:Input left";
                }

                {
                  output = "right:Out";
                  input = "crossfeed:Input right";
                }
              ];
            };

            "capture.props" = {
              "node.name" = "cloud3_fir_bs2b";
              "node.description" = "Cloud III FIR + BS2B";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."94-sofa" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "SOFA";

            "filter.graph" = {
              nodes = [
                {
                  type = "sofa";
                  name = "spatial";

                  label = "spatializer";

                  config = {
                    filename = sofaFile;
                    gain = -9.0;
                    normalize = true;
                  };

                  control = {
                    "Azimuth" = 30.0;
                    "Elevation" = 0.0;
                    "Radius" = 1.0;
                  };
                }
              ];

              inputs = [
                "spatial:In"
              ];

              outputs = [
                "spatial:Out L"
                "spatial:Out R"
              ];
            };

            "capture.props" = {
              "node.name" = "sofa";
              "node.description" = "SOFA";
              "media.class" = "Audio/Sink";
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."95-earpods-fir-sofa" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "EarPods FIR + SOFA";

            "filter.graph" = {
              nodes = [
                {
                  type = "sofa";
                  name = "spatial";

                  label = "spatializer";

                  config = {
                    filename = sofaFile;
                    gain = -9.0;
                    normalize = true;
                  };

                  control = {
                    "Azimuth" = 30.0;
                    "Elevation" = 0.0;
                    "Radius" = 1.0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "left";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "right";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/earpods_stereo/earpods_stereo minimum phase 192000Hz.wav";
                    channel = 1;
                  };
                }
              ];

              inputs = [
                "spatial:In"
              ];

              outputs = [
                "left:Out"
                "right:Out"
              ];

              links = [
                {
                  output = "spatial:Out L";
                  input = "left:In";
                }

                {
                  output = "spatial:Out R";
                  input = "right:In";
                }
              ];
            };

            "capture.props" = {
              "node.name" = "earpods_fir_sofa";
              "node.description" = "EarPods FIR + SOFA";
              "media.class" = "Audio/Sink";
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
    extraConfig.pipewire."96-cloud3-fir-sofa" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "Cloud III FIR + SOFA";

            "filter.graph" = {
              nodes = [
                {
                  type = "sofa";
                  name = "spatial";

                  label = "spatializer";

                  config = {
                    filename = sofaFile;
                    gain = -9.0;
                    normalize = true;
                  };

                  control = {
                    "Azimuth" = 30.0;
                    "Elevation" = 0.0;
                    "Radius" = 1.0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "left";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "right";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/output/cloud3_stereo/cloud3_stereo minimum phase 192000Hz.wav";
                    channel = 1;
                  };
                }
              ];

              inputs = [
                "spatial:In"
              ];

              outputs = [
                "left:Out"
                "right:Out"
              ];

              links = [
                {
                  output = "spatial:Out L";
                  input = "left:In";
                }

                {
                  output = "spatial:Out R";
                  input = "right:In";
                }
              ];
            };

            "capture.props" = {
              "node.name" = "cloud3_fir_sofa";
              "node.description" = "Cloud III FIR + SOFA";
              "media.class" = "Audio/Sink";
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
            };
          };
        }
      ];
    };
  };

  # Seatd for wlroots compositors (sway)
  services.dbus.enable = true;
  services.seatd.enable = true;
  services.libinput.enable = true; #input driver stack (mice, touchpads, etc.)

  services.resolved.enable = true;

  services.usbmuxd.enable = true;

  # xdg portal enabling
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  #security
  security.polkit = {
    enable = true;
    enablePkexecWrapper = true;    
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.user == "joel") {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # solaar
  services.solaar = {
    enable = true;
    window = "show";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22000 8384 ];
    allowedUDPPorts = [ 22000 21027 ];
  };

  services.tailscale.enable = true;

  # Fprintd
  services.fprintd.enable = true;
  security.pam.services = {
    system-local-login.fprintAuth = true;
    su.fprintAuth = true;
    system-auth.fprintAuth = true;
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    greetd.fprintAuth = true;
    swaylock = {
      enable = true;
      fprintAuth = true;
      unixAuth = true;
    };
  };
}
