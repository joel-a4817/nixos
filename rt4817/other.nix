{ config, lib, pkgs, ... }:

{
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

  # warp
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };

  # solaar
  services.solaar = {
    enable = true;
    window = "show";
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8384 53317 ]; #syncthing, localsend
    allowedUDPPorts = [ 53317 ];
  };

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
    }
  };
}
