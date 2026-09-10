{ config, lib, pkgs, ... }:

{
  programs.appimage = {
    enable = true;
    binfmt = true;

    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: [
        pkgs.webkitgtk_4_1
        pkgs.libsoup_3

        pkgs.mpv
        pkgs.libepoxy
        pkgs.gtk3
        pkgs.glib
        pkgs.pango
        pkgs.harfbuzz
        pkgs.cairo
        pkgs.gdk-pixbuf
        pkgs.atk
        pkgs.fontconfig
        pkgs.zlib
        pkgs.stdenv.cc.cc
      ];
    };
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
    (pkgs.python3.withPackages (python-pkgs: with python-pkgs; [ evdev pip ])) 
    (pkgs.bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ pkgs.python3Packages.psutil ];
    })) xhost procps util-linux
    mesa libva libva-utils #graphics
    temurin-jre-bin #java
    wget git gh
    wmenu swaybg autotiling
    grim slurp wf-recorder wl-clipboard
    pulseaudio brightnessctl
    imv mpv unzip zip
    qt6.qtwayland #qt apps in home-manager
    usbutils steam-run
    yt-dlp cdrkit dvdplusrwtools
    ffmpeg-full p7zip fzf zoxide resvg imagemagick jq #yazi pkgs (jq rotation script too), ffmpeg-full needed for music convert
    trash-cli lazygit fd ripgrep nushell ripdrag #required by yazi plugins
    libimobiledevice
    opencv
    alsa-utils bs2b-lv2
  ];
}
