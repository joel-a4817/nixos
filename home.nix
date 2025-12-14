
{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Packages for your setup
  home.packages = with pkgs; [
    prismlauncher
    signal-desktop
    vscode gitkraken
    kicad
    prusa-slicer bambu-studio
    curl gsettings-desktop-schemas #for timezones
  ];

  # Foot terminal config
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=monospace:size=16
  ''; 
}
