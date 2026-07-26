{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  imports = [
    ./home-pkgs.nix
  ];

  home.file.".config/nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
'';

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.foot = {
    enable = true;
    settings.main.font = "JetBrainsMono Nerd Font:size=16";
  };

  programs.fastfetch.enable = true;
}
