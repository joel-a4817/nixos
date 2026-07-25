{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.nix-ld.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [ evdev ])) procps util-linux
    temurin-jre-bin #java
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    appimage-run 
  ];

  nixpkgs.config.allowUnfree = true;
}
