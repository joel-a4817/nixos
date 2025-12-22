
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
    vscode
    kicad
    prusa-slicer
    bambu-studio
    opencv
    qt5.qtwayland
  ];

programs.fastfetch.enable = true;

}


