{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  services.syncthing = {
    enable = true;
  };

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

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = null;
  };

  programs.foot = {
    enable = true;
    settings.main.font = "JetBrainsMono Nerd Font:size=16";
  };

  programs.fastfetch.enable = true;
}
