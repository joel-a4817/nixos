{ config, lib, pkgs, ... }:

{
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
    (pkgs.bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ pkgs.python3Packages.psutil ];
    })) xhost
    mesa libva libva-utils #graphics
    temurin-jre-bin #java
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    appimage-run
    qt6.qtwayland #qt apps in home-manager
    usbutils steam-run
    yt-dlp cdrkit dvdplusrwtools
    ffmpeg p7zip fzf zoxide resvg imagemagick jq #yazi pkgs (jq rotation script too)
    trash-cli lazygit fd ripgrep nushell ripdrag #required by yazi plugins
    libimobiledevice
    opencv
  ];
}
