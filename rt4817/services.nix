{ config, lib, pkgs, ... }:

{
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
      name = "BrotherPrinterHome";
      location = "home";
      deviceUri = "ipp://192.168.0.25/ipp/print";
      model = "everywhere";
    }
  ];
};

systemd.services.ensure-printers = {
  wants = [
    "network-online.target"
  ];

  after = [
    "network-online.target"
    "cups.service"
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
