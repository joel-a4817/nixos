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

  # Allows externally downloaded Linux binaries, including the
  # Theos iOS toolchain, to run on NixOS.
  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      stdenv.cc.cc
      glibc
      libedit
      ncurses
      zlib
      z3
      libxml2
      util-linux
    ];
  };

  # System-wide Theos location.
  environment.sessionVariables = {
    THEOS = "/opt/theos";
  };

  environment.systemPackages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      evdev
      pip
      soundfile
      numpy
    ]))

    (bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ python3Packages.psutil ];
    }))

    xhost
    procps
    util-linux

    # Graphics
    mesa
    libva
    libva-utils

    # Java
    temurin-jre-bin

    # Development and Git
    wget
    git
    gh

    # Sway
    wmenu
    swaybg
    autotiling
    grim
    slurp
    wf-recorder
    wl-clipboard

    # Audio and hardware
    pulseaudio
    brightnessctl
    alsa-utils
    nqptp
    usbutils
    libimobiledevice

    # Media and applications
    imv
    mpv
    ffmpeg
    opencv

    # Archives and optical media
    unzip
    zip
    p7zip
    cdrkit
    dvdplusrwtools

    # Qt applications from Home Manager
    qt6.qtwayland

    # Compatibility
    steam-run

    # Yazi and scripts
    fzf
    zoxide
    resvg
    imagemagick
    jq
    trash-cli
    lazygit
    fd
    ripgrep
    nushell
    ripdrag

    # Theos build dependencies
    bash
    coreutils
    curl
    gnumake
    gnused
    gnugrep
    gawk
    findutils
    which
    file
    rsync
    perl
    python3

    dpkg
    fakeroot

    libxml2
    ncurses
    zlib
    z3
    libedit

    clang
    lld
    llvm

    xz
    gzip
    bzip2
    gnutar

    openssh
    ldid
  ];
}
