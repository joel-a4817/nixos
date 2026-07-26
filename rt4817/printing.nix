{ config, lib, pkgs, ... }:

{
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
}

