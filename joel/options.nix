{ config, pkgs, lib, ... }:
{
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

  programs.mpv = {
    enable = true;
    config = {
      input-ipc-server = "/tmp/mpvsocket";
    };
  };

  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
  };
}
