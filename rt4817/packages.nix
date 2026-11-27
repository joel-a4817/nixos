{ config, lib, pkgs, ... }:

let
  swayJsonC = pkgs.json_c.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      target=json_object.c
      broken='assert(_json_object_put_maybe_free(jso, 1) == 0);'

      grep -Fq "$broken" "$target" || {
        echo "Expected vulnerable json-c 0.19 source line was not found" >&2
        exit 1
      }

      substituteInPlace "$target" \
        --replace-fail "$broken" \
        'int json_c_put_result_f291fa81c = _json_object_put_maybe_free(jso, 1); assert(json_c_put_result_f291fa81c == 0);'
    '';
  });

  # Keep Sway as an overridable package, as required by the NixOS Sway module.
  # Only Sway ELF files directly linked to libjson-c receive the private patched
  # json-c path. The rest of the system keeps the original json-c derivation.
  swayWithJsonCFix = pkgs.sway.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.patchelf ];
    postFixup = (old.postFixup or "") + ''
      patched=0
      while IFS= read -r file; do
        if patchelf --print-needed "$file" 2>/dev/null | grep -Fxq libjson-c.so.5; then
          old_rpath="$(patchelf --print-rpath "$file")"
          patchelf --set-rpath "${swayJsonC}/lib:$old_rpath" "$file"
          patched=$((patched + 1))
        fi
      done < <(find "$out" -type f)

      test "$patched" -gt 0 || {
        echo "No Sway ELF file linked to libjson-c.so.5 was found" >&2
        exit 1
      }
    '';
  });
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
    package = swayWithJsonCFix;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
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
      evdev pip numpy soundfile scipy h5py psutil matplotlib pandas pyyaml netcdf4 requests platformdirs
  ])) #bunch of the audio pkgs
    web-ext
    glib

    (bleachbit.overridePythonAttrs (old: {
      propagatedBuildInputs =
        (old.propagatedBuildInputs or [])
        ++ [ python3Packages.psutil ];
    }))
    xhost procps 
    util-linux exfatprogs dosfstools ntfs3g e2fsprogs parted

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
    sonobus
    libplist frida-tools #ipad website stuff
    socat wayvnc playerctl

    # Media and applications
    imv mpv ffmpeg

    # Archives and optical media
    unzip zip p7zip cdrkit dvdplusrwtools

    # Qt applications from Home Manager
    qt6.qtwayland

    mcrcon

    # Compatibility
    steam-run

    # Yazi and scripts
    fzf zoxide resvg imagemagick jq trash-cli lazygit fd ripgrep nushell
    ripdrag

    gnome-themes-extra #dark theme

    # Theos build dependencies
    bash coreutils curl gnumake gnused gnugrep gawk findutils which file rsync perl dpkg fakeroot libxml2 ncurses zlib z3 libedit clang lld llvm xz gzip bzip2 gnutar ldid

    kbd #sway shell

    android-tools
  ];
}
