{ config, lib, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix

    ./rt4817/system.nix
    ./rt4817/udev-lid.nix
    ./rt4817/users.nix
    ./rt4817/wayland.nix
    ./rt4817/fonts.nix
    ./rt4817/packages.nix
    ./rt4817/virtualisation.nix
    ./rt4817/services.nix
  ];

  system.stateVersion = "25.11";
}
