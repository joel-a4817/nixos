{ config, lib, pkgs, ... }:

{
  imports = [
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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org"
      "https://chaotic-nyx.cachix.org"
      "https://nix-community.cachix.org"
      "https://yazi.cachix.org"
      "https://cachix-action.cachix.org"
    ];
    trusted-public-keys = [
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="
      "cachix-action.cachix.org-1:y4Dd8m5DCPMKmhgbInx10qNsnFCsVopL6zPB0iGaN40="
    ];
  };

  system.stateVersion = "25.11";
}
