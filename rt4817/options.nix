{ config, lib, pkgs, ... }:

let
  earpodsFilter = pkgs.writeText "earpods_flat.txt" ''
    Preamp: -11.0 dB
    Filter 1: ON LSC Fc 20 Hz Gain 11.0 dB Q 0.50
    Filter 2: ON PK Fc 65 Hz Gain 6.2 dB Q 0.70
    Filter 3: ON PK Fc 240 Hz Gain -3.5 dB Q 1.20
    Filter 4: ON PK Fc 1100 Hz Gain 4.0 dB Q 0.90
    Filter 5: ON PK Fc 3200 Hz Gain -8.5 dB Q 2.10
    Filter 6: ON PK Fc 5500 Hz Gain 3.0 dB Q 1.80
    Filter 7: ON PK Fc 7100 Hz Gain -9.0 dB Q 3.50
    Filter 8: ON PK Fc 12000 Hz Gain 5.0 dB Q 2.00
  '';

  cloud3Filter = pkgs.writeText "cloud3_flat.txt" ''
    Preamp: -4.5 dB
    Filter 1: ON LSC Fc 35 Hz Gain 4.5 dB Q 0.60
    Filter 2: ON PK Fc 160 Hz Gain -4.2 dB Q 1.10
    Filter 3: ON PK Fc 450 Hz Gain 2.0 dB Q 1.40
    Filter 4: ON PK Fc 1800 Hz Gain 3.5 dB Q 2.00
    Filter 5: ON PK Fc 3150 Hz Gain -7.0 dB Q 2.80
    Filter 6: ON PK Fc 4800 Hz Gain -3.0 dB Q 3.00
    Filter 7: ON PK Fc 6300 Hz Gain -9.5 dB Q 4.00
    Filter 8: ON PK Fc 14000 Hz Gain 4.0 dB Q 1.50
  '';
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

    extraConfig.pipewire = {
      "99-flat-headphones" = {
        "context.modules" = [
          {
            name = "libpipewire-module-parametric-equalizer";
            args = {
              "equalizer.filepath" = "${earpodsFilter}";
              "equalizer.description" = "EarPods Flat";

              "capture.props" = {
                "node.name" = "earpods-flat";
                "node.description" = "EarPods Flat";
              };

              "playback.props" = {
                "node.name" = "earpods-flat-output";
                "node.description" = "EarPods Flat";
              };
            };
          }
          {
            name = "libpipewire-module-parametric-equalizer";
            args = {
              "equalizer.filepath" = "${cloud3Filter}";
              "equalizer.description" = "Cloud III Flat";

              "capture.props" = {
                "node.name" = "cloud3-flat";
                "node.description" = "Cloud III Flat";
              };

              "playback.props" = {
                "node.name" = "cloud3-flat-output";
                "node.description" = "Cloud III Flat";
              };
            };
          }
        ];
      };
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
