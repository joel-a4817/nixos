{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  imports = [
    ./joel/xcompose-greek.nix
    ./joel/modules.nix
    ./joel/packages.nix
  ];
}
