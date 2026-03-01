{ config, lib, pkgs, ... }:

{

  networking.hostName = "rt4817";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings = {
    max-jobs = 1;
    cores = 1;
  };

  boot.kernelModules = [ "uinput" ];

  # Boot (UEFI)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
