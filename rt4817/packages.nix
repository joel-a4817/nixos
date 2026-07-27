{ config, lib, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.xwayland.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    (pkgs.python3.withPackages (ps: with ps; [ evdev ])) procps util-linux
    mesa libva libva-utils #graphics
    temurin-jre-bin #java
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    appimage-run
    qt6.qtwayland #qt apps in home-manager
    heimdall-gui android-tools #lineageos
    libimobiledevice ifuse #ios
    usbutils steam-run
    yt-dlp cdrkit dvdplusrwtools
  ];
}
