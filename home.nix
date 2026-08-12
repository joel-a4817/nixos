{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  imports = [
    ./joel/packages.nix
    ./joel/options.nix
  ];

  home.file.".config/nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
'';
}
