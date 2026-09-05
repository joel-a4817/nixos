{ config, lib, pkgs, ... }:

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
