
{ config, pkgs, lib, ... }:

{
  home.username = "joel";
  home.homeDirectory = "/home/joel";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # Packages for your setup
  home.packages = with pkgs; [
    prismlauncher #https://wiki.nixos.org/wiki/Prism_Launcher
    signal-desktop #no official for nix
    vscode #https://wiki.nixos.org/wiki/Visual_Studio_Code 
    gitkraken #snap-store official: https://snapcraft.io/gitkraken
    kicad #flatpak official: https://www.kicad.org/download/linux/
    prusa-slicer #appimage official: https://prusaslicer.net/#download 
    bambu-studio #flatpak official: https://flathub.org/en/apps/com.bambulab.BambuStudio
    opencv #git official: https://docs.opencv.org/4.12.0/d7/d9f/tutorial_linux_install.html
    qt5.qtwayland
  ];
}
