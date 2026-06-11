{ config, lib, pkgs, ... }:

{
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

  # Printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.printing = {
    enable = true;
    defaultShared = true;
    allowFrom = [ "all" ];
    listenAddresses = [ "*:631" ];
    drivers = with pkgs; [
      cups-filters
    ];
  };

  services.samba = {
    enable = true;
    settings.global.workgroup = "ADMINISTRATION";
  };
  
  hardware.printers = {
    ensureDefaultPrinter = "BrotherPrinterHome";
    ensurePrinters = [
      {
        deviceUri = "socket://192.168.0.25:9100";
        location = "home";
        name = "BrotherPrinterHome";
        model = "everywhere";
      }
    ];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
  };
  networking.firewall.allowedTCPPorts = [ 8384 9191 ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
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
  };
  security.pam.services.swaylock = {
    enable = true;
    fprintAuth = true;
    unixAuth = true;
  };
}
