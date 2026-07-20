{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [ evdev ])) procps util-linux
    libimobiledevice ifuse usbmuxd usbutils steam-run #run all binaries
    temurin-jre-bin
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    appimage-run 
  ];

  nixpkgs.config.allowUnfree = true;
}
