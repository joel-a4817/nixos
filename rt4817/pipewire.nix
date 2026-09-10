{ config, lib, pkgs, ... }:
let
  ladspa-bs2b = pkgs.callPackage ./ladspa-bs2b.nix {};
  sofaFile = "${pkgs.libmysofa}/share/libmysofa/MIT_KEMAR_normal_pinna.sofa";
in
{
# Audio (PipeWire + WirePlumber)
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
    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 96000; #max for ASH sinks
        "default.clock.allowed-rates" = [
          32000
          44100
          48000
          88200
          96000
          #176400 -> ASH sinks don't need
          #192000
        ];
      };
    };
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
    extraConfig.pipewire."97-earpods-ash" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "EarPods ASH";

            "filter.graph" = {
              nodes = [
                {
                  type = "builtin";
                  label = "copy";
                  name = "splitL";
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "splitR";
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/Apple_EarPods_Averaged_Measurements.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/Apple_EarPods_Averaged_Measurements.wav";
                    channel = 1;
                  };
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "postL";
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "postR";
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/BRIR_True_Stereo.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/BRIR_True_Stereo.wav";
                    channel = 1;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/BRIR_True_Stereo.wav";
                    channel = 2;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset earpods/BRIR_True_Stereo.wav";
                    channel = 3;
                  };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                }
              ];

              links = [
                { output = "splitL:Out"; input = "hpcfL:In"; }
                { output = "splitR:Out"; input = "hpcfR:In"; }

                { output = "hpcfL:Out"; input = "postL:In"; }
                { output = "hpcfR:Out"; input = "postR:In"; }

                { output = "postL:Out"; input = "LL:In"; }
                { output = "postL:Out"; input = "LR:In"; }

                { output = "postR:Out"; input = "RL:In"; }
                { output = "postR:Out"; input = "RR:In"; }

                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }

                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
              ];

              inputs = [
                "splitL:In"
                "splitR:In"
              ];

              outputs = [
                "mixL:Out"
                "mixR:Out"
              ];
            };

            "capture.props" = {
              "node.name" = "earpods_ash";
              "node.description" = "EarPods ASH";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };
    extraConfig.pipewire."98-cloud3-ash" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "Cloud III ASH";

            "filter.graph" = {
              nodes = [
                {
                  type = "builtin";
                  label = "copy";
                  name = "splitL";
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "splitR";
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/HyperX_Cloud_III_Rtings.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/HyperX_Cloud_III_Rtings.wav";
                    channel = 1;
                  };
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "postL";
                }

                {
                  type = "builtin";
                  label = "copy";
                  name = "postR";
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/BRIR_True_Stereo.wav";
                    channel = 0;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/BRIR_True_Stereo.wav";
                    channel = 1;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/BRIR_True_Stereo.wav";
                    channel = 2;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";

                  config = {
                    filename = "/home/joel/Documents/prefs/audio/ASH-Toolset cloud3/BRIR_True_Stereo.wav";
                    channel = 3;
                  };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                }
              ];

              links = [
                { output = "splitL:Out"; input = "hpcfL:In"; }
                { output = "splitR:Out"; input = "hpcfR:In"; }

                { output = "hpcfL:Out"; input = "postL:In"; }
                { output = "hpcfR:Out"; input = "postR:In"; }

                { output = "postL:Out"; input = "LL:In"; }
                { output = "postL:Out"; input = "LR:In"; }

                { output = "postR:Out"; input = "RL:In"; }
                { output = "postR:Out"; input = "RR:In"; }

                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }

                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
              ];

              inputs = [
                "splitL:In"
                "splitR:In"
              ];

              outputs = [
                "mixL:Out"
                "mixR:Out"
              ];
            };

            "capture.props" = {
              "node.name" = "cloud3_ash";
              "node.description" = "Cloud III ASH";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };
  };
}
