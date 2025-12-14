
{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Packages for your setup
  home.packages = with pkgs; [
    prismlauncher #https://wiki.nixos.org/wiki/Prism_Launcher
    signal-desktop #only other is snap-store
    vscode #https://wiki.nixos.org/wiki/Visual_Studio_Code 
    gitkraken #only other is snap-store
    kicad #only other is flathub
    prusa-slicer #need appimage 
    bambu-studio #need flathub
    curl gsettings-desktop-schemas #for timezones
  ];

  # Foot terminal config
  xdg.configFile."foot/foot.ini".text = ''
    [main]
    font=monospace:size=16
  ''; 
}
