{ config, lib, pkgs, ... }:

let
  resetHyperXDac = pkgs.writeShellScriptBin "reset-hyperx-dac" ''
    set -euo pipefail

    device=""

    for productFile in /sys/bus/usb/devices/*/product
    do
      if [ ! -r "$productFile" ]; then
        continue
      fi

      product="$(
        cat "$productFile"
      )"

      case "$product" in
        *Cloud*III*)
          device="$(
            basename "$(
              dirname "$productFile"
            )"
          )"
          break
          ;;
      esac
    done

    if [ -z "$device" ]; then
      echo "HyperX Cloud III USB device not found" >&2
      exit 1
    fi

    echo "Resetting HyperX USB device $device"

    printf '%s' "$device" \
      > /sys/bus/usb/drivers/usb/unbind

    sleep 2

    printf '%s' "$device" \
      > /sys/bus/usb/drivers/usb/bind

    attempt=1

    while [ "$attempt" -le 12 ]
    do
      if grep -Fq '[III' /proc/asound/cards
      then
        echo "HyperX Cloud III returned as ALSA card III"
        exit 0
      fi

      sleep 1
      attempt="$((attempt + 1))"
    done

    echo "USB device returned, but ALSA card III did not" >&2
    exit 1
  '';
in
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
    evdev pip soundfile numpy
    ]))

    (bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ python3Packages.psutil ];
    }))
    xhost procps util-linux

    # Graphics
    mesa libva libva-utils

    # Java
    temurin-jre-bin

    # Development and Git
    wget git gh

    # Sway
    wmenu swaybg autotiling grim slurp wf-recorder wl-clipboard

    # Audio and hardware
    pulseaudio brightnessctl alsa-utils camilladsp nqptp usbutils libimobiledevice psmisc # for web script 
    resetHyperXDac sonobus

    # Media and applications
    imv mpv ffmpeg opencv

    # Archives and optical media
    unzip zip p7zip cdrkit dvdplusrwtools

    # Qt applications from Home Manager
    qt6.qtwayland

    # Compatibility
    steam-run

    # Yazi and scripts
    fzf zoxide resvg imagemagick jq trash-cli lazygit fd ripgrep nushell ripdrag

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
