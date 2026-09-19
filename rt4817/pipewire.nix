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

    extraConfig.pipewire."00-earpods-abies-grandis-forest-wheldrake-wood" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Abies Grandis Forest, Wheldrake Wood";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Abies Grandis Forest, Wheldrake Wood/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_abies-grandis-forest-wheldrake-wood";
              "node.description" = "earpods - Abies Grandis Forest, Wheldrake Wood";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."01-earpods-anechoic-ie" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Anechoic (IE)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (IE)/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_anechoic-ie";
              "node.description" = "earpods - Anechoic (IE)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."02-earpods-athenee-theatre-main-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Athenee Theatre - Main Hall, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Athenee Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_athenee-theatre-main-hall-v2";
              "node.description" = "earpods - Athenee Theatre - Main Hall, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."03-earpods-detmold-konzerthaus-medium-sized-concert-hall-600-seats" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Detmold Konzerthaus (medium sized concert hall, ~600 seats).";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Detmold Konzerthaus (medium sized concert hall, ~600 seats)./BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_detmold-konzerthaus-medium-sized-concert-hall-600-seats";
              "node.description" = "earpods - Detmold Konzerthaus (medium sized concert hall, ~600 seats).";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."04-earpods-elveden-hall-suffolk-england-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Elveden Hall (Suffolk England) - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Elveden Hall (Suffolk England) - v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_elveden-hall-suffolk-england-v2";
              "node.description" = "earpods - Elveden Hall (Suffolk England) - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."05-earpods-falkland-palace-royal-tennis-court-v3" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Falkland Palace Royal Tennis Court - v3";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Falkland Palace Royal Tennis Court - v3/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_falkland-palace-royal-tennis-court-v3";
              "node.description" = "earpods - Falkland Palace Royal Tennis Court - v3";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."06-earpods-hoffmann-lime-kiln-langcliffe-uk" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Hoffmann Lime Kiln (Langcliffe, UK)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Hoffmann Lime Kiln (Langcliffe, UK)/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_hoffmann-lime-kiln-langcliffe-uk";
              "node.description" = "earpods - Hoffmann Lime Kiln (Langcliffe, UK)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."07-earpods-karlsruhe-state-theatre-main-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Karlsruhe State Theatre - Main Hall, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Karlsruhe State Theatre - Main Hall, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_karlsruhe-state-theatre-main-hall-v2";
              "node.description" = "earpods - Karlsruhe State Theatre - Main Hall, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."08-earpods-laubenheim-barn-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Laubenheim - Barn, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Laubenheim - Barn, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_laubenheim-barn-v2";
              "node.description" = "earpods - Laubenheim - Barn, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."09-earpods-les-dominicains-de-haute-alsace-neo-gothic-chapel-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_les-dominicains-de-haute-alsace-neo-gothic-chapel-v2";
              "node.description" = "earpods - Les Dominicains de Haute-Alsace - Neo-Gothic Chapel, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."10-earpods-main-auditorium-of-the-finnish-national-opera-and-ballet-fnob" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Main auditorium of the Finnish National Opera and Ballet (FNOB)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Main auditorium of the Finnish National Opera and Ballet (FNOB)/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_main-auditorium-of-the-finnish-national-opera-and-ballet-fnob";
              "node.description" = "earpods - Main auditorium of the Finnish National Opera and Ballet (FNOB)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."11-earpods-promenadikeskus-concert-hall-in-pori-finland" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Promenadikeskus concert hall in Pori, Finland";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Promenadikeskus concert hall in Pori, Finland/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_promenadikeskus-concert-hall-in-pori-finland";
              "node.description" = "earpods - Promenadikeskus concert hall in Pori, Finland";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."12-earpods-singer-polignac-foundation-music-salon-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Singer-Polignac Foundation - Music Salon, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Singer-Polignac Foundation - Music Salon, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_singer-polignac-foundation-music-salon-v2";
              "node.description" = "earpods - Singer-Polignac Foundation - Music Salon, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."13-earpods-small-hall-of-the-konzerthaus-berlin" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Small hall of the Konzerthaus Berlin";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Small hall of the Konzerthaus Berlin/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_small-hall-of-the-konzerthaus-berlin";
              "node.description" = "earpods - Small hall of the Konzerthaus Berlin";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."14-earpods-spesbourg-castle-main-building-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Spesbourg Castle - Main Building, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Spesbourg Castle - Main Building, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_spesbourg-castle-main-building-v2";
              "node.description" = "earpods - Spesbourg Castle - Main Building, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."15-earpods-strasbourg-observatory-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Strasbourg Observatory, v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Strasbourg Observatory, v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_strasbourg-observatory-v2";
              "node.description" = "earpods - Strasbourg Observatory, v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."16-earpods-tyndall-bruce-monument-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Tyndall Bruce Monument - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Tyndall Bruce Monument - v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_tyndall-bruce-monument-v2";
              "node.description" = "earpods - Tyndall Bruce Monument - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."17-earpods-usina-del-arte-symphony-hall-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - Usina del Arte Symphony Hall - v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Usina del Arte Symphony Hall - v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_usina-del-arte-symphony-hall-v2";
              "node.description" = "earpods - Usina del Arte Symphony Hall - v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."18-earpods-york-minsters-chapter-house" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - York Minster's Chapter House";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/York Minster's Chapter House/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_york-minsters-chapter-house";
              "node.description" = "earpods - York Minster's Chapter House";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."19-earpods-zkm-karlsruhe-mezzanine-rear-v2" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "earpods - ZKM Karlsruhe - Mezzanine (Rear), v2";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/ZKM Karlsruhe - Mezzanine (Rear), v2/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "earpods_zkm-karlsruhe-mezzanine-rear-v2";
              "node.description" = "earpods - ZKM Karlsruhe - Mezzanine (Rear), v2";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };

    extraConfig.pipewire."20-cloud3-anechoic-oe" = {
      "context.modules" = [
        {
          name = "libpipewire-module-filter-chain";

          args = {
            "node.description" = "cloud3 - Anechoic (OE)";

            "filter.graph" = {
              nodes = [
                { type = "builtin"; label = "copy"; name = "splitL"; }
                { type = "builtin"; label = "copy"; name = "splitR"; }

                {
                  type = "builtin";
                  label = "convolver";
                  name = "LL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 0; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "LR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 1; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RL";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 2; };
                }
                {
                  type = "builtin";
                  label = "convolver";
                  name = "RR";
                  config = { filename = "/home/joel/Documents/prefs/audio/BRIRs/Anechoic (OE)/BRIR_True_Stereo.wav"; channel = 3; };
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
              "node.name" = "cloud3_anechoic-oe";
              "node.description" = "cloud3 - Anechoic (OE)";
              "media.class" = "Audio/Sink";
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };

            "playback.props" = {
              "audio.channels" = 2;
              "audio.position" = [ "FL" "FR" ];
              "audio.rate" = 96000;
              "stream.dont-remix" = true;
            };
          };
        }
      ];
    };
  };
}
