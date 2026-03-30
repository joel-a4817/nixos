{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix

    ./rt4817/hardware.nix
    ./rt4817/users.nix
    ./rt4817/display.nix
    ./rt4817/fonts.nix
    ./rt4817/packages.nix
    ./rt4817/virtualisation.nix
    ./rt4817/services.nix
  ];

  networking.hostName = "rt4817";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    max-jobs = 2;
    cores = 2;
  };

  system.stateVersion = "25.11";
}
