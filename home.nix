
{ config, pkgs, lib, ... }:
{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  # Cursor settings
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    gtk.enable = true;
    x11.enable = true;
  };

  # User packages (no wrapper scripts)
  home.packages = with pkgs; [
    prismlauncher
    signal-desktop
    kicad
    prusa-slicer
    bambu-studio
    opencv
    qt5.qtwayland
  ];

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=16";
      };
      colors = {
        foreground = "ffffff";
        background = "101010";
        alpha = 0.88;
      };
    };
  };

programs.fastfetch.enable = true;

}


