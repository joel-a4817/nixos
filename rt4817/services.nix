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
    package = pkgs.solaar;
    window = "show";
    extraArgs = "--headless";
  };

  # Printing
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  hardware.printers = {
    ensureDefaultPrinter = "BrotherPrinterHome";
    ensurePrinters = [
      {
        deviceUri = "dnssd://Brother%20MFC-L2750DW%20series._ipp._tcp.local/?uuid=e3248000-80ce-11db-8000-3c2af4f6c121";
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
  networking.firewall.allowedTCPPorts = [ 8384 ];

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
