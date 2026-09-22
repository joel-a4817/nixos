{ config, lib, pkgs, ... }:
{
  # Audio (PipeWire + WirePlumber)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-clock" = {
      "context.properties" = {
        "default.clock.rate" = 96000;
        "default.clock.allowed-rates" = [
          32000
          44100
          48000
          88200
          96000 #hyperx dac supports up to 96khz
        ];
      };
    };

    extraConfig.pipewire."00-earpods-0000ms-anechoic-ie" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (0000ms) Anechoic (IE)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.31988951096913981;
                    "Gain 2" = 0.31988951096913981;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.31988951096913981;
                    "Gain 2" = 0.31988951096913981;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_0000ms-anechoic-ie";
              "node.description" = "earpods - (0000ms) Anechoic (IE)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."01-cloud3-0000ms-anechoic-oe" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "cloud3 - (0000ms) Anechoic (OE)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0000ms) Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.11091748152624009;
                    "Gain 2" = 0.11091748152624009;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.11091748152624009;
                    "Gain 2" = 0.11091748152624009;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/HyperX_Cloud_III_Average.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/HyperX_Cloud_III_Average.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "cloud3_0000ms-anechoic-oe";
              "node.description" = "cloud3 - (0000ms) Anechoic (OE)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."02-earpods-0737ms-spesbourg-castle-main-building-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (0737ms) Spesbourg Castle - Main Building, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0737ms) Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0737ms) Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0737ms) Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0737ms) Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.16032453906900412;
                    "Gain 2" = 0.16032453906900412;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.16032453906900412;
                    "Gain 2" = 0.16032453906900412;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_0737ms-spesbourg-castle-main-building-v2";
              "node.description" = "earpods - (0737ms) Spesbourg Castle - Main Building, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."03-earpods-0775ms-elveden-hall-suffolk-england-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (0775ms) Elveden Hall (Suffolk England) - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0775ms) Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0775ms) Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0775ms) Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0775ms) Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.18620871366628675;
                    "Gain 2" = 0.18620871366628675;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.18620871366628675;
                    "Gain 2" = 0.18620871366628675;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_0775ms-elveden-hall-suffolk-england-v2";
              "node.description" = "earpods - (0775ms) Elveden Hall (Suffolk England) - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."04-earpods-0777ms-hoffmann-lime-kiln-langcliffe-uk" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (0777ms) Hoffmann Lime Kiln (Langcliffe, UK)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0777ms) Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0777ms) Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0777ms) Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0777ms) Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.14962356560944334;
                    "Gain 2" = 0.14962356560944334;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.14962356560944334;
                    "Gain 2" = 0.14962356560944334;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_0777ms-hoffmann-lime-kiln-langcliffe-uk";
              "node.description" = "earpods - (0777ms) Hoffmann Lime Kiln (Langcliffe, UK)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."05-earpods-0840ms-laubenheim-barn-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (0840ms) Laubenheim - Barn, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0840ms) Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0840ms) Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0840ms) Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(0840ms) Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.15488166189124816;
                    "Gain 2" = 0.15488166189124816;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.15488166189124816;
                    "Gain 2" = 0.15488166189124816;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_0840ms-laubenheim-barn-v2";
              "node.description" = "earpods - (0840ms) Laubenheim - Barn, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."06-earpods-1199ms-abies-grandis-forest-wheldrake-wood" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1199ms) Abies Grandis Forest, Wheldrake Wood";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1199ms) Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1199ms) Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1199ms) Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1199ms) Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.16982436524617442;
                    "Gain 2" = 0.16982436524617442;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.16982436524617442;
                    "Gain 2" = 0.16982436524617442;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1199ms-abies-grandis-forest-wheldrake-wood";
              "node.description" = "earpods - (1199ms) Abies Grandis Forest, Wheldrake Wood";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."07-earpods-1223ms-les-dominicains-de-haute-alsace-neo-gothic-chapel-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.14288939585111030;
                    "Gain 2" = 0.14288939585111030;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.14288939585111030;
                    "Gain 2" = 0.14288939585111030;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1223ms-les-dominicains-de-haute-alsace-neo-gothic-chapel-v2";
              "node.description" = "earpods - (1223ms) Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."08-earpods-1285ms-small-hall-of-the-konzerthaus-berlin" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1285ms) Small hall of the Konzerthaus Berlin";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1285ms) Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1285ms) Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1285ms) Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1285ms) Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.13803842646028849;
                    "Gain 2" = 0.13803842646028849;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.13803842646028849;
                    "Gain 2" = 0.13803842646028849;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1285ms-small-hall-of-the-konzerthaus-berlin";
              "node.description" = "earpods - (1285ms) Small hall of the Konzerthaus Berlin";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."09-earpods-1334ms-strasbourg-observatory-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1334ms) Strasbourg Observatory, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1334ms) Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1334ms) Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1334ms) Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1334ms) Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.16595869074375605;
                    "Gain 2" = 0.16595869074375605;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.16595869074375605;
                    "Gain 2" = 0.16595869074375605;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1334ms-strasbourg-observatory-v2";
              "node.description" = "earpods - (1334ms) Strasbourg Observatory, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."10-earpods-1343ms-singer-polignac-foundation-music-salon-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1343ms) Singer-Polignac Foundation - Music Salon, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1343ms) Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1343ms) Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1343ms) Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1343ms) Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.15667510701081488;
                    "Gain 2" = 0.15667510701081488;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.15667510701081488;
                    "Gain 2" = 0.15667510701081488;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1343ms-singer-polignac-foundation-music-salon-v2";
              "node.description" = "earpods - (1343ms) Singer-Polignac Foundation - Music Salon, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."11-earpods-1345ms-falkland-palace-royal-tennis-court-v3" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1345ms) Falkland Palace Royal Tennis Court - v3";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1345ms) Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1345ms) Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1345ms) Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1345ms) Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.17782794100389229;
                    "Gain 2" = 0.17782794100389229;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.17782794100389229;
                    "Gain 2" = 0.17782794100389229;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1345ms-falkland-palace-royal-tennis-court-v3";
              "node.description" = "earpods - (1345ms) Falkland Palace Royal Tennis Court - v3";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."12-earpods-1347ms-athenee-theatre-main-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1347ms) Athenee Theatre - Main Hall, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1347ms) Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1347ms) Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1347ms) Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1347ms) Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.16218100973589297;
                    "Gain 2" = 0.16218100973589297;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.16218100973589297;
                    "Gain 2" = 0.16218100973589297;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1347ms-athenee-theatre-main-hall-v2";
              "node.description" = "earpods - (1347ms) Athenee Theatre - Main Hall, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."13-earpods-1426ms-karlsruhe-state-theatre-main-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1426ms) Karlsruhe State Theatre - Main Hall, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1426ms) Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1426ms) Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1426ms) Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1426ms) Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.16595869074375605;
                    "Gain 2" = 0.16595869074375605;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.16595869074375605;
                    "Gain 2" = 0.16595869074375605;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1426ms-karlsruhe-state-theatre-main-hall-v2";
              "node.description" = "earpods - (1426ms) Karlsruhe State Theatre - Main Hall, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."14-earpods-1443ms-detmold-konzerthaus-medium-sized-concert-hall-600-seats" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats).";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.13963683610559374;
                    "Gain 2" = 0.13963683610559374;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.13963683610559374;
                    "Gain 2" = 0.13963683610559374;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1443ms-detmold-konzerthaus-medium-sized-concert-hall-600-seats";
              "node.description" = "earpods - (1443ms) Detmold Konzerthaus (medium sized concert hall, ~600 seats).";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."15-earpods-1531ms-tyndall-bruce-monument-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1531ms) Tyndall Bruce Monument - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1531ms) Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1531ms) Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1531ms) Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1531ms) Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.17579236139586926;
                    "Gain 2" = 0.17579236139586926;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.17579236139586926;
                    "Gain 2" = 0.17579236139586926;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1531ms-tyndall-bruce-monument-v2";
              "node.description" = "earpods - (1531ms) Tyndall Bruce Monument - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."16-earpods-1578ms-usina-del-arte-symphony-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1578ms) Usina del Arte Symphony Hall - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1578ms) Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1578ms) Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1578ms) Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1578ms) Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.15848931924611134;
                    "Gain 2" = 0.15848931924611134;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.15848931924611134;
                    "Gain 2" = 0.15848931924611134;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1578ms-usina-del-arte-symphony-hall-v2";
              "node.description" = "earpods - (1578ms) Usina del Arte Symphony Hall - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."17-earpods-1599ms-main-auditorium-of-the-finnish-national-opera-and-ballet-fnob" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.11885022274370183;
                    "Gain 2" = 0.11885022274370183;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.11885022274370183;
                    "Gain 2" = 0.11885022274370183;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1599ms-main-auditorium-of-the-finnish-national-opera-and-ballet-fnob";
              "node.description" = "earpods - (1599ms) Main auditorium of the Finnish National Opera and Ballet (FNOB)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."18-earpods-1806ms-zkm-karlsruhe-mezzanine-rear-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.15135612484362082;
                    "Gain 2" = 0.15135612484362082;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.15135612484362082;
                    "Gain 2" = 0.15135612484362082;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_1806ms-zkm-karlsruhe-mezzanine-rear-v2";
              "node.description" = "earpods - (1806ms) ZKM Karlsruhe - Mezzanine (Rear), v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."19-earpods-2264ms-promenadikeskus-concert-hall-in-pori-finland" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (2264ms) Promenadikeskus concert hall in Pori, Finland";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(2264ms) Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(2264ms) Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(2264ms) Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(2264ms) Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.12882495516931339;
                    "Gain 2" = 0.12882495516931339;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.12882495516931339;
                    "Gain 2" = 0.12882495516931339;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_2264ms-promenadikeskus-concert-hall-in-pori-finland";
              "node.description" = "earpods - (2264ms) Promenadikeskus concert hall in Pori, Finland";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."20-earpods-4400ms-york-minsters-chapter-house" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - (4400ms) York Minster's Chapter House";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(4400ms) York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(4400ms) York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(4400ms) York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/(4400ms) York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 3; };
                }

                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixL";
                  control = {
                    "Gain 1" = 0.13489628825916539;
                    "Gain 2" = 0.13489628825916539;
                  };
                }
                {
                  type = "builtin";
                  label = "mixer";
                  name = "mixR";
                  control = {
                    "Gain 1" = 0.13489628825916539;
                    "Gain 2" = 0.13489628825916539;
                  };
                }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfL";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "hpcfR";
                  config = { filename = "/home/joel/Documents/prefs/audio/Apple_EarPods_Ahastyle_Covers_Custom_Average_A+B.wav"; channel = 1; };
                }
              ];

              links = [
                { output = "splitL:Out"; input = "LL:In"; }
                { output = "splitL:Out"; input = "LR:In"; }
                { output = "splitR:Out"; input = "RL:In"; }
                { output = "splitR:Out"; input = "RR:In"; }
                { output = "LL:Out"; input = "mixL:In 1"; }
                { output = "RL:Out"; input = "mixL:In 2"; }
                { output = "LR:Out"; input = "mixR:In 1"; }
                { output = "RR:Out"; input = "mixR:In 2"; }
                { output = "mixL:Out"; input = "hpcfL:In"; }
                { output = "mixR:Out"; input = "hpcfR:In"; }
              ];

              inputs = [ "splitL:In" "splitR:In" ];
              outputs = [ "hpcfL:Out" "hpcfR:Out" ];
            };

            "capture.props" = {
              "node.name" = "earpods_4400ms-york-minsters-chapter-house";
              "node.description" = "earpods - (4400ms) York Minster's Chapter House";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
            };

            "playback.props" = {
              "node.autoconnect" = false;
              "node.dont-fallback" = true;
              "stream.dont-remix" = true;
              "state.restore-target" = false;
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
